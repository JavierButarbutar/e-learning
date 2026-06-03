import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notifikasi_guru_model.dart';
import '../../../../../core/storage/shared_pref.dart';
import '../../../../../core/constants/api_endpoints.dart';

class NotifikasiGuruRepository {
  static Future<Map<String, dynamic>> getNotifikasi({int page = 1}) async {
    try {
      final token = await SharedPref.getToken();

      final response = await http.get(
        Uri.parse('${ApiEndpoint.notifikasi}?page=$page&per_page=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];

        return {
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
      debugPrint('ERROR GURU NOTIF: $e');
      rethrow;
    }
  }

  static Future<void> bacaNotifikasi(int id) async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse(ApiEndpoint.bacaNotifikasi(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  static Future<void> bacaSemua() async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse(ApiEndpoint.bacaSemuaNotifikasi),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await SharedPref.getToken();
    if (token == null) return;

    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoint.updateFcmToken),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fcm_token': fcmToken}),
          )
          .timeout(const Duration(seconds: 8));

      debugPrint('UPDATE FCM TOKEN: ${response.statusCode}');
    } on TimeoutException {
      debugPrint('UPDATE FCM TOKEN: timeout');
    } catch (e) {
      debugPrint('UPDATE FCM TOKEN error: $e');
    }
  }
}