import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON wrapper over browser storage. Never throws: unreadable or
/// tampered data comes back as null, failed writes return false.
class LocalStore {
  LocalStore._();

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static Future<Object?> read(String key) async {
    final raw = (await _prefs())?.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> write(String key, Object value) async {
    final p = await _prefs();
    if (p == null) return false;
    try {
      return await p.setString(key, jsonEncode(value));
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> readList(String key) async {
    final v = await read(key);
    if (v is! List) return [];
    return v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Future<Map<String, dynamic>> readMap(String key) async {
    final v = await read(key);
    return v is Map ? Map<String, dynamic>.from(v) : {};
  }
}

/// Fired whenever coins, results, bookings or the profile change, so every
/// open tab can refresh.
class AppEvents extends ChangeNotifier {
  AppEvents._();
  static final AppEvents instance = AppEvents._();
  void changed() => notifyListeners();
}
