import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _rememberKey = 'remember';
  static const String _isLoginKey = 'is_login';
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  static Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> setRemember(bool value) async {
  final prefs = await _prefs();
  await prefs.setBool(_rememberKey, value);
}

  // ================= USER (FULL DATA) =================
  static Future<void> saveUser(Map<String, dynamic> user) async {
  final prefs = await _prefs();
  await prefs.setString(_userKey, jsonEncode(user));
}

static Future<Map<String, dynamic>?> getUser() async {
  final prefs = await _prefs();
  final data = prefs.getString(_userKey);

  if (data == null) return null;

  try {
    return jsonDecode(data);
  } catch (e) {
    return null;
  }
}

  // ================= SAVE LOGIN =================
  static Future<void> saveLogin({
    required String email,
    required String role,
    required bool remember,
  }) async {
    final prefs = await _prefs();

    await prefs.setString(_emailKey, email);
    await prefs.setString(_roleKey, role);
    await prefs.setBool(_rememberKey, remember);
  }

  // ================= TOKEN =================
  static Future<void> saveToken(String token) async {
    final prefs = await _prefs();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs();
    return prefs.getString(_tokenKey);
  }

  // ================= LOGIN STATUS =================
  static Future<void> setLogin(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_isLoginKey, value);
  }

  static Future<bool> getLogin() async {
    final prefs = await _prefs();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  // ================= GET DATA =================
  static Future<String?> getEmail() async {
    final prefs = await _prefs();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getRole() async {
    final prefs = await _prefs();
    return prefs.getString(_roleKey);
  }

  static Future<bool> getRemember() async {
    final prefs = await _prefs();
    return prefs.getBool(_rememberKey) ?? false;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await _prefs();

    await prefs.setBool(_isLoginKey, false);

    // hapus data penting
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    bool remember = prefs.getBool(_rememberKey) ?? false;

    if (!remember) {
      await prefs.remove(_emailKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_rememberKey);
    }
  }

  // ================= CLEAR ALL (OPTIONAL) =================
  static Future<void> clearAll() async {
    final prefs = await _prefs();
    await prefs.clear();
  }
}