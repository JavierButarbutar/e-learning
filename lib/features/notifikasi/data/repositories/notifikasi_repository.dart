import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notifikasi_model.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../../../core/constants/api_endpoints.dart';

class NotifikasiRepository {
  static Future<Map<String, dynamic>> getNotifikasi({int page = 1}) async {
    try {
      final token = await SharedPref.getToken();

      print("TOKEN: $token");

      final response = await http.get(
        Uri.parse('${ApiEndpoint.notifikasi}?page=$page&per_page=20'),
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

  static Future<int> getUnreadCount() async {
    final token = await SharedPref.getToken();
    final response = await http.get(
      Uri.parse(ApiEndpoint.unreadNotifikasi),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']['unread_count'] ?? 0;
    }
    return 0;
  }

  static Future<void> bacaNotifikasi(int id) async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse(ApiEndpoint.bacaNotifikasi(id)),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  static Future<void> bacaSemua() async {
    final token = await SharedPref.getToken();
    await http.post(
      Uri.parse(ApiEndpoint.bacaSemuaNotifikasi),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await SharedPref.getToken();
    if (token == null) {
      debugPrint("FCM UPDATE SKIP: auth token null");
      return;
    }

    debugPrint("KIRIM FCM TOKEN: $fcmToken");

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

      debugPrint(
        "RESPONSE UPDATE TOKEN: ${response.statusCode} ${response.body}",
      );

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
