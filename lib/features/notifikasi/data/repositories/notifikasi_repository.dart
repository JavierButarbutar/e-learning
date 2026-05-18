import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notifikasi_model.dart';
import '../../../../core/storage/shared_pref.dart'; // sesuaikan path SharedPref-mu

class NotifikasiRepository {
  static const String _baseUrl = 'http://192.168.137.1:8000/api'; // ganti domain

  // ── GET /api/notifikasi ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifikasi({int page = 1}) async {
  try {
    final token = await SharedPref.getToken();

    print("TOKEN: $token");

    final response = await http.get(
      Uri.parse('$_baseUrl/notifikasi?page=$page&per_page=20'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];

      return {
        'data': list.map((e) => NotifikasiModel.fromJson(e)).toList(),
        'unread_count': body['unread_count'] ?? 0,
        'pagination': body['pagination'],
      };
    }

    throw Exception(response.body);
  } catch (e) {
    print("ERROR NOTIFIKASI: $e");
    rethrow;
  }
}

  // ── GET /api/notifikasi/unread-count ─────────────────────────────────────
  static Future<int> getUnreadCount() async {
    final token = await SharedPref.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/notifikasi/unread-count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']['unread_count'] ?? 0;
    }
    return 0;
  }

  // ── POST /api/notifikasi/{id}/baca ───────────────────────────────────────
  static Future<void> bacaNotifikasi(int id) async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse('$_baseUrl/notifikasi/$id/baca'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ── POST /api/notifikasi/baca-semua ──────────────────────────────────────
  static Future<void> bacaSemua() async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse('$_baseUrl/notifikasi/baca-semua'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ── POST /api/notifikasi/update-token ────────────────────────────────────
  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse('$_baseUrl/notifikasi/update-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  }
}