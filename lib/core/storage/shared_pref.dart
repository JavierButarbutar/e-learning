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

  // ================= USER =================

  /// 🔥 SIMPAN USER (dipakai saat login / fetch API)
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await _prefs();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// 🔥 ALIAS BIAR GA ERROR DI SCREEN (setUser sering dipanggil)
  static Future<void> setUser(Map<String, dynamic> user) async {
    await saveUser(user);
  }

  /// 🔥 AMBIL USER (ANTI CRASH)
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _prefs();
    final data = prefs.getString(_userKey);

    if (data == null) return null;

    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🔥 UPDATE SEBAGIAN DATA USER (tanpa overwrite semua)
  static Future<void> updateUser(Map<String, dynamic> newData) async {
    final prefs = await _prefs();

    final currentUser = await getUser() ?? {};

    currentUser.addAll(newData);

    await prefs.setString(_userKey, jsonEncode(currentUser));
  }

  // ================= FOTO =================
  static Future<String?> getFoto() async {
    final user = await getUser();

    final foto = user?['foto'];

    if (foto != null &&
        foto.toString().isNotEmpty &&
        foto.toString().startsWith('http')) {
      return foto.toString();
    }

    return null;
  }

  // ================= LOGIN =================
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

  // ================= STATUS LOGIN =================
  static Future<void> setLogin(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_isLoginKey, value);
  }

  static Future<bool> getLogin() async {
    final prefs = await _prefs();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  // ================= GET BASIC DATA =================
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
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    bool remember = prefs.getBool(_rememberKey) ?? false;

    if (!remember) {
      await prefs.remove(_emailKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_rememberKey);
    }
  }

  // ================= CLEAR ALL =================
  static Future<void> clearAll() async {
    final prefs = await _prefs();
    await prefs.clear();
  }
}