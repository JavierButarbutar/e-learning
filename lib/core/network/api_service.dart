import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../../features/guru/dashboard/data/models/jadwal_model.dart';
import 'api_debug.dart';

class ApiService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.login;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({
      "email": email,
      "password": password,
      if (fcmToken != null) "fcm_token": fcmToken,
    });

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'],
        "statusCode": response.statusCode,
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  static Future<Map<String, dynamic>> getStudentProfile({
    required String token,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.studentProfile;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    ApiDebug.logRequest(method: 'GET', url: url, headers: headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'GET',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'] ?? {},
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'GET',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
        "data": {},
      };
    }
  }

  static Future<Map<String, dynamic>> updateStudentProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.updateStudentProfile;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode(data);

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final res = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": res['success'] ?? false,
        "message": res['message'] ?? '',
        "data": res['data'] ?? {},
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
        "data": {},
      };
    }
  }

  static Future<Map<String, dynamic>> checkEmail({
    required String email,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.checkEmail;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({"email": email});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.sendOtp;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({"email": email});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.verifyOtp;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({"email": email, "otp": otp});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "statusCode": response.statusCode,
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'],
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.resetPassword;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({"email": email, "password": password});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.updatePassword;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode({
      "old_password": oldPassword,
      "new_password": newPassword,
    });

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "statusCode": response.statusCode,
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  static Future<Map<String, dynamic>> updateEmail({
    required String token,
    required String email,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.updateEmail;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode({"email": email});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
        "data": data['data'],
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, dynamic>> logout({required String token}) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.logout;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? '',
      };
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return _errorResponse("Tidak dapat terhubung ke server");
    }
  }

  static Future<Map<String, List<JadwalItem>>> getJadwalGuru({
    required String token,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.jadwalGuruSemua;
    final headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    ApiDebug.logRequest(method: 'GET', url: url, headers: headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      final data = _safeDecode(response.body);

      ApiDebug.logResponse(
        method: 'GET',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      if (response.statusCode != 200 ||
          data == null ||
          data['success'] != true) {
        return {};
      }
      final minggu = data['data']?['jadwal_minggu'] as List? ?? [];
      Map<String, List<JadwalItem>> hasil = {};

      for (final item in minggu) {
        final hariLabel = item['label']?.toString() ?? '';

        final jadwalList = item['jadwal'] as List? ?? [];

        hasil[hariLabel] = jadwalList.map((e) {
          return JadwalItem.fromJson({...e, 'hari_label': hariLabel});
        }).toList();
      }

      return hasil;
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'GET',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return {};
    }
  }

  static Future<void> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = ApiEndpoint.updateFcmToken;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode({"fcm_token": fcmToken});

    ApiDebug.logRequest(method: 'POST', url: url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();

      ApiDebug.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebug.logError(
        method: 'POST',
        url: url,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

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
    return {"success": false, "message": message};
  }
}
