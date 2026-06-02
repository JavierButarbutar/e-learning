import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiDebug {
  static const String _tag = '═══ API DEBUG ═══';
  static const String _border = '═════════════════════════════════════════';

  /// Log API Request
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n$_border');
    debugPrint('📤 REQUEST');
    debugPrint(_border);
    debugPrint('🕐 Time: ${DateTime.now()}');
    debugPrint('🔗 URL: $url');
    debugPrint('📋 Method: $method');

    if (headers != null && headers.isNotEmpty) {
      debugPrint('\n📌 Headers:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          debugPrint('  ├─ $key: Bearer ••••••••');
        } else {
          debugPrint('  ├─ $key: $value');
        }
      });
    }

    if (body != null) {
      debugPrint('\n📦 Body:');
      try {
        if (body is String) {
          final decoded = jsonDecode(body);
          debugPrint(_prettyJson(decoded));
        } else {
          debugPrint(_prettyJson(body));
        }
      } catch (e) {
        debugPrint('  $body');
      }
    }

    debugPrint('$_border\n');
  }

  /// Log API Response
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    String? body,
    int? durationMs,
  }) {
    if (!kDebugMode) return;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    final isError = statusCode >= 400;
    final statusEmoji = isSuccess ? '✅' : isError ? '❌' : '⚠️ ';

    debugPrint('\n$_border');
    debugPrint('📥 RESPONSE');
    debugPrint(_border);
    debugPrint('🕐 Time: ${DateTime.now()}');
    debugPrint('🔗 URL: $url');
    debugPrint('📋 Method: $method');
    debugPrint('$statusEmoji Status Code: $statusCode');

    if (durationMs != null) {
      debugPrint('⏱️ Duration: ${durationMs}ms');
    }

    if (headers != null && headers.isNotEmpty) {
      debugPrint('\n📌 Response Headers:');
      headers.forEach((key, value) {
        debugPrint('  ├─ $key: $value');
      });
    }

    if (body != null && body.isNotEmpty) {
      debugPrint('\n📦 Response Body:');
      try {
        final decoded = jsonDecode(body);
        debugPrint(_prettyJson(decoded));
      } catch (e) {
        debugPrint('  (Raw Text):');
        debugPrint('  $body');
      }
    }

    debugPrint('$_border\n');
  }

  /// Log Error
  static void logError({
    required String method,
    required String url,
    required String error,
    StackTrace? stackTrace,
    int? durationMs,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n$_border');
    debugPrint('❌ ERROR');
    debugPrint(_border);
    debugPrint('🕐 Time: ${DateTime.now()}');
    debugPrint('🔗 URL: $url');
    debugPrint('📋 Method: $method');
    debugPrint('💥 Error: $error');

    if (durationMs != null) {
      debugPrint('⏱️ Duration: ${durationMs}ms');
    }

    if (stackTrace != null) {
      debugPrint('\n📍 Stack Trace:');
      debugPrint(stackTrace.toString());
    }

    debugPrint('$_border\n');
  }

  /// Log custom message
  static void log({
    required String title,
    required String message,
    String? subtitle,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n$_border');
    debugPrint('ℹ️ $title');
    debugPrint(_border);
    if (subtitle != null) {
      debugPrint('📝 $subtitle');
    }
    debugPrint('💬 $message');
    debugPrint('$_border\n');
  }

  /// Pretty print JSON
  static String _prettyJson(Object? json, {int indent = 2}) {
    try {
      String jsonString = '';

      if (json is String) {
        jsonString = json;
      } else {
        jsonString = jsonEncode(json);
      }

      final object = jsonDecode(jsonString);
      final encoder = JsonEncoder.withIndent(' ' * indent);
      final pretty = encoder.convert(object);

      return pretty.split('\n').map((line) => '  $line').join('\n');
    } catch (e) {
      return '  (Unable to format JSON: $e)';
    }
  }

  /// Log with custom style
  static void logCustom({
    required String emoji,
    required String title,
    required String content,
  }) {
    if (!kDebugMode) return;

    debugPrint('\n$_border');
    debugPrint('$emoji $title');
    debugPrint(_border);
    debugPrint(content);
    debugPrint('$_border\n');
  }

  /// Get status message
  static String getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK - Request berhasil';
      case 201:
        return 'Created - Resource berhasil dibuat';
      case 204:
        return 'No Content - Request berhasil, tidak ada data';
      case 400:
        return 'Bad Request - Request tidak valid';
      case 401:
        return 'Unauthorized - Token tidak valid atau kadaluarsa';
      case 403:
        return 'Forbidden - Akses ditolak';
      case 404:
        return 'Not Found - Resource tidak ditemukan';
      case 500:
        return 'Internal Server Error - Kesalahan server';
      case 502:
        return 'Bad Gateway - Server tidak merespons';
      case 503:
        return 'Service Unavailable - Server sedang maintenance';
      default:
        return 'HTTP $statusCode';
    }
  }
}
