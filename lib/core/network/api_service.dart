import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';

class ApiService {
  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.login),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = _safeDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "success": data['success'] ?? false,
        "message": data['message'] ?? 'Terjadi kesalahan',
        "data": data['data'],
      };
    } catch (e) {
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> checkEmail({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.checkEmail),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = _safeDecode(response.body);

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  // ================= SEND OTP =================
  static Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.sendOtp),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = _safeDecode(response.body);

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
  required String email,
  required String otp,
}) async {
  try {
    final response = await http.post(
      Uri.parse(ApiEndpoint.verifyOtp),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    final data = _safeDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "success": data['success'] ?? false,
      "message": data['message'] ?? '',
      "data": data['data'],
    };
  } catch (e) {
    return _errorResponse("Tidak dapat terhubung ke server");
  }
}

static Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse(ApiEndpoint.resetPassword),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = _safeDecode(response.body);

    return {
      "success": data['success'] ?? false,
      "message": data['message'] ?? '',
    };
  } catch (e) {
    return _errorResponse("Tidak dapat terhubung ke server");
  }
}

  // ================= HELPER =================
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }

  static Map<String, dynamic> _errorResponse(String message) {
    return {
      "success": false,
      "message": message,
    };
  }
}
