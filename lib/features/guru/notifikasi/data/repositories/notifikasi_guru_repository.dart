import 'dart:async';                        // untuk TimeoutException
import 'package:flutter/foundation.dart';   // untuk debugPrint
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notifikasi_guru_model.dart';
import '../../../../../core/storage/shared_pref.dart';

class NotifikasiGuruRepository {
  static const String _baseUrl =
      'https://loan-eco-chen-speech.trycloudflare.com/api';

  static Future<Map<String, dynamic>> getNotifikasi({int page = 1}) async {
    try {
      final token = await SharedPref.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/notifikasi?page=$page&per_page=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("GURU NOTIF STATUS: ${response.statusCode}");
      print("GURU NOTIF BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];

        return {
          // Filter hanya tipe jadwal_guru
          'data': list
              .map((e) => NotifikasiGuruModel.fromJson(e))
              .where((n) => n.tipe == 'jadwal')
              .toList(),
          'unread_count': body['unread_count'] ?? 0,
          'pagination': body['pagination'],
        };
      }

      throw Exception(response.body);
    } catch (e) {
      print("ERROR GURU NOTIF: $e");
      rethrow;
    }
  }

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

  static Future<void> updateFcmToken(String fcmToken) async {
  final token = await SharedPref.getToken();
  if (token == null) return;

  debugPrint("KIRIM FCM TOKEN: $fcmToken"); 

  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/notifikasi/update-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    ).timeout(const Duration(seconds: 8));

     debugPrint("RESPONSE UPDATE TOKEN: ${response.statusCode} ${response.body}");

    // Optional: log kalau gagal tapi jangan rethrow
    // FCM token update bukan operasi kritis — gagal pun app tetap jalan
    if (response.statusCode != 200) {
      debugPrint("FCM token update failed: ${response.statusCode}");
    }
  } on TimeoutException {
    debugPrint("FCM token update timeout");
  } catch (e) {
    debugPrint("FCM token update error: $e");
  }
}
}