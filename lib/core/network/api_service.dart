import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../../features/guru/dashboard/data/models/jadwal_model.dart';

class ApiService {

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    // role dihapus — backend menentukan role dari database
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
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'],
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }

  // ================= GET STUDENT PROFILE =================
  static Future<Map<String, dynamic>> getStudentProfile({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoint.studentProfile),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = _safeDecode(response.body);

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'] ?? {},
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
        "data": {},
      };
    }
  }

  // ================= UPDATE STUDENT PROFILE =================
  static Future<Map<String, dynamic>> updateStudentProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.updateStudentProfile),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      final res = _safeDecode(response.body);

      return {
        "success": res['success'] ?? false,
        "message": res['message'] ?? '',
        "data": res['data'] ?? {},
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
        "data": {},
      };
    }
  }

  // ================= CHECK EMAIL =================
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

  // ================= VERIFY OTP =================
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

  // ================= RESET PASSWORD =================
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

  // ================= UPDATE PASSWORD =================
  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.updatePassword),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      final data = _safeDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }

  // ================= UPDATE EMAIL =================
  static Future<Map<String, dynamic>> updateEmail({
    required String token,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.updateEmail),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = _safeDecode(response.body);

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'],
      };
    } catch (e) {
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  // ================= LOGOUT =================
  static Future<Map<String, dynamic>> logout({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.logout),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
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

 // ================= GET JADWAL GURU =================

static Future<Map<String, List<JadwalItem>>> getJadwalGuru({
  required String token,
}) async {
  try {
    final response = await http.get(
      Uri.parse(ApiEndpoint.jadwalGuruSemua),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = _safeDecode(response.body);

    // DEBUG RESPONSE
    print("STATUS CODE : ${response.statusCode}");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("DATA : $data");

    // Validasi response
    if (response.statusCode != 200 ||
        data == null ||
        data['success'] != true) {
      return {};
    }

    // Ambil jadwal minggu
    final minggu =
        data['data']?['jadwal_minggu'] as List? ?? [];

    // Penampung hasil
    Map<String, List<JadwalItem>> hasil = {};

    for (final item in minggu) {
      final hariLabel =
          item['label']?.toString() ?? '';

      final jadwalList =
          item['jadwal'] as List? ?? [];

      hasil[hariLabel] = jadwalList.map((e) {
        return JadwalItem.fromJson({
          ...e,
          'hari_label': hariLabel,
        });
      }).toList();
    }

    return hasil;
  } catch (e) {
    print("ERROR GET JADWAL GURU : $e");
    return {};
  }
}

static Future<void> updateFcmToken({
  required String token,
  required String fcmToken,
}) async {

  try {

    print(ApiEndpoint.updateFcmToken);

    final response = await http.post(
      Uri.parse(ApiEndpoint.updateFcmToken),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "fcm_token": fcmToken,
      }),
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

  } catch (e) {

    print("ERROR UPDATE TOKEN : $e");

  }
}

  // ================= HELPER =================
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
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