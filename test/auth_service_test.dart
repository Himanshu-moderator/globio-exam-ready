import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:globio_exam_ready/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final auth = AuthService.instance;

  Future<void> fresh([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    auth.resetForTest();
    await auth.init();
  }

  test('PBKDF2 matches the RFC 7914 test vector (1 iteration)', () {
    // PBKDF2-HMAC-SHA256("passwd", "salt", c=1, dkLen=32) first block.
    final key = base64Url.decode(AuthService.deriveKey('passwd', 'salt', 1));
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(hex, '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc');
  });

  test('sign up stores no plain-text password and starts a session', () async {
    await fresh();
    final err = await auth.signUp(name: ' Asha Rao ', email: 'Asha@Example.com', password: 'secret123');
    expect(err, isNull);
    expect(auth.currentUser?.email, 'asha@example.com');
    expect(auth.currentUser?.firstName, 'Asha');

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('globio.users.v2')!;
    expect(raw.contains('secret123'), isFalse);
  });

  test('duplicate email is rejected (case-insensitive)', () async {
    await fresh();
    await auth.signUp(name: 'Asha', email: 'asha@example.com', password: 'secret123');
    await auth.logOut();
    final err = await auth.signUp(name: 'Other', email: 'ASHA@example.com', password: 'secret456');
    expect(err, contains('already exists'));
  });

  test('weak or invalid input is rejected by the service, not just the UI', () async {
    await fresh();
    expect(await auth.signUp(name: 'A', email: 'a@b.co', password: 'secret123'), isNotNull);
    expect(await auth.signUp(name: 'Asha', email: 'not-an-email', password: 'secret123'), isNotNull);
    expect(await auth.signUp(name: 'Asha', email: 'a@b.co', password: 'short1'), isNotNull);
    expect(await auth.signUp(name: 'Asha', email: 'a@b.co', password: 'lettersonly'), isNotNull);
    expect(await auth.signUp(name: 'Asha', email: 'a@b.co', password: 'a1' * 70), isNotNull);
    expect(auth.isSignedIn, isFalse);
  });

  test('log in works, wrong password and unknown email give the same message', () async {
    await fresh();
    await auth.signUp(name: 'Asha', email: 'asha@example.com', password: 'secret123');
    await auth.logOut();
    expect(await auth.logIn(email: 'asha@example.com', password: 'wrong999'), AuthService.badCredentials);
    expect(await auth.logIn(email: 'nobody@example.com', password: 'secret123'), AuthService.badCredentials);
    expect(await auth.logIn(email: ' ASHA@example.com ', password: 'secret123'), isNull);
    expect(auth.isSignedIn, isTrue);
  });

  test('five wrong passwords trigger a cooldown, even for the right password', () async {
    await fresh();
    await auth.signUp(name: 'Asha', email: 'asha@example.com', password: 'secret123');
    await auth.logOut();
    String? last;
    for (var i = 0; i < AuthService.maxFailedAttempts; i++) {
      last = await auth.logIn(email: 'asha@example.com', password: 'wrong999');
    }
    expect(last, contains('Too many attempts'));
    expect(await auth.logIn(email: 'asha@example.com', password: 'secret123'), contains('Too many attempts'));
    expect(auth.isSignedIn, isFalse);
  });

  test('session survives a restart; logout clears it', () async {
    await fresh();
    await auth.signUp(name: 'Asha', email: 'asha@example.com', password: 'secret123');
    final prefs = await SharedPreferences.getInstance();
    final stored = <String, Object>{
      'globio.users.v2': prefs.getString('globio.users.v2')!,
      'globio.session.v2': prefs.getString('globio.session.v2')!,
    };
    await fresh(stored);
    expect(auth.currentUser?.name, 'Asha');
    await auth.logOut();
    expect(auth.isSignedIn, isFalse);
  });

  test('corrupted or tampered storage never crashes', () async {
    await fresh({'globio.users.v2': '{not json', 'globio.session.v2': 'x@y.z'});
    expect(auth.isSignedIn, isFalse);
    expect(await auth.logIn(email: 'x@y.z', password: 'secret123'), AuthService.badCredentials);

    await fresh({
      'globio.users.v2': jsonEncode({
        'x@y.z': {'name': 5, 'salt': [], 'hash': null, 'iter': 'lots'},
      }),
      'globio.session.v2': 'x@y.z',
    });
    expect(auth.isSignedIn, isFalse);
    expect(await auth.logIn(email: 'x@y.z', password: 'secret123'), AuthService.badCredentials);
  });

  test('a session pointing at a missing account is dropped', () async {
    await fresh({'globio.session.v2': 'ghost@example.com'});
    expect(auth.isSignedIn, isFalse);
  });
}
