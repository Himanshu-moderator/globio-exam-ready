import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A signed-in learner.
class AppUser {
  const AppUser({required this.name, required this.email});
  final String name;
  final String email;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }
}

/// Input limits shared by the UI and the service.
class AuthLimits {
  AuthLimits._();
  static const nameMin = 2;
  static const nameMax = 60;
  static const emailMax = 254;
  static const passwordMin = 8;
  static const passwordMax = 128;

  static final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.length < nameMin) return 'Please enter your name';
    if (s.length > nameMax) return 'Name must be at most $nameMax characters';
    return null;
  }

  static String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.length > emailMax || !emailPattern.hasMatch(s)) return 'Please enter a valid email';
    return null;
  }

  static String? validateNewPassword(String? v) {
    final s = v ?? '';
    if (s.length < passwordMin) return 'Use at least $passwordMin characters';
    if (s.length > passwordMax) return 'Use at most $passwordMax characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Use at least one letter and one number';
    }
    return null;
  }
}

/// Local-only authentication.
///
/// There is no backend: accounts live in the browser's local storage
/// (via shared_preferences). Nothing is sent anywhere, there is no email
/// confirmation and no Google sign-in.
///
/// Passwords are never stored in plain text. They are stretched with
/// PBKDF2-HMAC-SHA256 and a random per-user salt, and compared in constant
/// time. Repeated wrong passwords trigger a short cooldown.
///
/// Note: because everything runs in the browser, this protects the password
/// itself, but it is not a substitute for server-side auth. That is by design
/// for this no-backend prototype.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _usersKey = 'globio.users.v2';
  static const _sessionKey = 'globio.session.v2';

  /// PBKDF2 work factor. Kept moderate so a login stays well under a second
  /// in the browser while making offline guessing far slower than plain SHA-256.
  static const pbkdf2Iterations = 20000;

  static const maxFailedAttempts = 5;
  static const lockoutDuration = Duration(seconds: 30);

  static const storageUnavailable =
      'Your browser is blocking local storage, so accounts cannot be saved. '
      'Please allow site data or try a normal (non-private) window.';
  static const badCredentials = 'Email or password is incorrect.';

  SharedPreferences? _prefs;
  AppUser? _current;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  AppUser? get currentUser => _current;
  bool get isSignedIn => _current != null;
  bool get storageAvailable => _prefs != null;

  /// Never throws: if storage is unavailable the app still runs, signed out.
  Future<void> init() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
      return;
    }
    final email = _prefs!.getString(_sessionKey);
    if (email == null) return;
    final record = _record(email);
    final name = record?['name'];
    if (name is String) {
      _current = AppUser(name: name, email: email);
    } else {
      await _safe(() => _prefs!.remove(_sessionKey));
    }
  }

  Map<String, dynamic> _users() {
    final raw = _prefs?.getString(_usersKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic>? _record(String email) {
    final r = _users()[email];
    return r is Map ? Map<String, dynamic>.from(r) : null;
  }

  static Future<bool> _safe(Future<bool> Function() op) async {
    try {
      return await op();
    } catch (_) {
      return false;
    }
  }

  static String _normalise(String email) => email.trim().toLowerCase();

  /// PBKDF2-HMAC-SHA256, one 32-byte block.
  @visibleForTesting
  static String deriveKey(String password, String salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final block = Uint8List.fromList([...utf8.encode(salt), 0, 0, 0, 1]);
    var u = hmac.convert(block).bytes;
    final out = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return base64Url.encode(out);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static String _newSalt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  /// Seconds left on the cooldown, or 0.
  int get lockoutSecondsLeft {
    final until = _lockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds;
    return left > 0 ? left + 1 : 0;
  }

  /// Returns `null` on success, otherwise a message to show the user.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_prefs == null) return storageUnavailable;
    final error = AuthLimits.validateName(name) ??
        AuthLimits.validateEmail(email) ??
        AuthLimits.validateNewPassword(password);
    if (error != null) return error;

    final key = _normalise(email);
    final users = _users();
    if (users.containsKey(key)) {
      return 'An account with this email already exists on this device. Please log in.';
    }
    final salt = _newSalt();
    users[key] = {
      'name': name.trim(),
      'salt': salt,
      'iter': pbkdf2Iterations,
      'hash': deriveKey(password, salt, pbkdf2Iterations),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (!await _safe(() => _prefs!.setString(_usersKey, jsonEncode(users)))) {
      return storageUnavailable;
    }
    return await _startSession(key, name.trim()) ? null : storageUnavailable;
  }

  /// Returns `null` on success, otherwise a message to show the user.
  Future<String?> logIn({required String email, required String password}) async {
    if (_prefs == null) return storageUnavailable;
    final wait = lockoutSecondsLeft;
    if (wait > 0) return 'Too many attempts. Please wait $wait seconds and try again.';
    if (password.isEmpty || password.length > AuthLimits.passwordMax) return badCredentials;

    final key = _normalise(email);
    final record = _record(key);
    final salt = record?['salt'];
    final hash = record?['hash'];
    final iter = record?['iter'];
    final name = record?['name'];

    final valid = salt is String &&
        hash is String &&
        iter is int &&
        iter > 0 &&
        iter <= 1000000 &&
        name is String &&
        _constantTimeEquals(deriveKey(password, salt, iter), hash);

    if (!valid) {
      _failedAttempts++;
      if (_failedAttempts >= maxFailedAttempts) {
        _failedAttempts = 0;
        _lockedUntil = DateTime.now().add(lockoutDuration);
        return 'Too many attempts. Please wait ${lockoutDuration.inSeconds} seconds and try again.';
      }
      return badCredentials;
    }
    _failedAttempts = 0;
    _lockedUntil = null;
    return await _startSession(key, name) ? null : storageUnavailable;
  }

  Future<bool> _startSession(String email, String name) async {
    if (!await _safe(() => _prefs!.setString(_sessionKey, email))) return false;
    _current = AppUser(name: name, email: email);
    notifyListeners();
    return true;
  }

  /// Changes the signed-in learner's display name. Returns null on success.
  Future<String?> updateName(String name) async {
    final user = _current;
    if (user == null || _prefs == null) return storageUnavailable;
    final err = AuthLimits.validateName(name);
    if (err != null) return err;
    final users = _users();
    final record = users[user.email];
    if (record is! Map) return 'Account not found.';
    users[user.email] = {...Map<String, dynamic>.from(record), 'name': name.trim()};
    if (!await _safe(() => _prefs!.setString(_usersKey, jsonEncode(users)))) return storageUnavailable;
    _current = AppUser(name: name.trim(), email: user.email);
    notifyListeners();
    return null;
  }

  Future<void> logOut() async {
    final prefs = _prefs;
    if (prefs != null) await _safe(() => prefs.remove(_sessionKey));
    _current = null;
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _prefs = null;
    _current = null;
    _failedAttempts = 0;
    _lockedUntil = null;
  }
}
