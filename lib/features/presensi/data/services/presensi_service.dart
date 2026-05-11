import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';

// ─────────────────────────────────────────────────────────────
// PRESENSI SERVICE
// Raw HTTP call + debug response
// ─────────────────────────────────────────────────────────────
class PresensiService {
  final http.Client _client;

  PresensiService({http.Client? client})
      : _client = client ?? http.Client();

  // ────────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────────
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ────────────────────────────────────────────────────────────
  // GET ACTIVE PRESENSI
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getActivePresensi(
    String token,
  ) async {
    final uri = Uri.parse(ApiEndpoint.presensiAktif);

    print('================ ACTIVE PRESENSI ================');
    print('URL: $uri');
    print('TOKEN: $token');

    final response = await _client.get(
      uri,
      headers: _headers(token),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseResponse(response);
  }

  // ────────────────────────────────────────────────────────────
  // POST SCAN QR
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> scanQr({
    required String token,
    required String qrCode,
    String? latitude,
    String? longitude,
  }) async {
    final uri = Uri.parse(ApiEndpoint.presensiScan);

    final body = json.encode({
      'qr_code': qrCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });

    print('================ SCAN QR ================');
    print('URL: $uri');
    print('TOKEN: $token');
    print('BODY REQUEST: $body');

    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: body,
    );

    print('STATUS: ${response.statusCode}');
    print('BODY RESPONSE: ${response.body}');

    return _parseResponse(response);
  }

  // ────────────────────────────────────────────────────────────
  // GET RIWAYAT
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getRiwayat(
    String token, {
    String? tanggalMulai,
    String? tanggalSelesai,
    int? mapelId,
    int page = 1,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (tanggalMulai != null)
        'tanggal_mulai': tanggalMulai,
      if (tanggalSelesai != null)
        'tanggal_selesai': tanggalSelesai,
      if (mapelId != null)
        'mapel_id': mapelId.toString(),
    };

    final uri = Uri.parse(ApiEndpoint.presensiRiwayat)
        .replace(queryParameters: queryParams);

    print('================ RIWAYAT ================');
    print('URL: $uri');
    print('TOKEN: $token');

    final response = await _client.get(
      uri,
      headers: _headers(token),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseResponse(response);
  }

  // ────────────────────────────────────────────────────────────
  // GET REKAP
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getRekap(
    String token, {
    int? bulan,
    int? tahun,
  }) async {
    final queryParams = {
      if (bulan != null) 'bulan': bulan.toString(),
      if (tahun != null) 'tahun': tahun.toString(),
    };

    final uri = Uri.parse(ApiEndpoint.presensiRekap)
        .replace(
      queryParameters:
          queryParams.isEmpty ? null : queryParams,
    );

    print('================ REKAP ================');
    print('URL: $uri');
    print('TOKEN: $token');

    final response = await _client.get(
      uri,
      headers: _headers(token),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseResponse(response);
  }

  // ────────────────────────────────────────────────────────────
  // PARSE RESPONSE
  // ────────────────────────────────────────────────────────────
  Map<String, dynamic> _parseResponse(
    http.Response response,
  ) {
    try {
      final decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw PresensiException(
          message: 'Format response server tidak valid',
          statusCode: response.statusCode,
        );
      }

      // SUCCESS
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return decoded;
      }

      // ERROR
      final message =
          decoded['message']?.toString() ??
              'Terjadi kesalahan pada server';

      throw PresensiException(
        message: message,
        statusCode: response.statusCode,
        data: decoded['data'] is Map<String, dynamic>
            ? decoded['data']
            : null,
      );
    } catch (e) {
      throw PresensiException(
        message:
            'Gagal parsing response server: $e',
        statusCode: response.statusCode,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM EXCEPTION
// ─────────────────────────────────────────────────────────────
class PresensiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;

  const PresensiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isSudahAbsen => statusCode == 409;

  bool get isExpiredOrJauh => statusCode == 422;

  @override
  String toString() {
    return 'PresensiException($statusCode): $message';
  }
}