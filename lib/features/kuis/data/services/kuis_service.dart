import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/kuis_model.dart';
import '../models/soal_model.dart';

/// Bertanggung jawab untuk semua komunikasi API kuis.
class KuisService {

  // ── Header helper ─────────────────────────────────────────────────────────
  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── 1. Detail kuis (sebelum mulai) ───────────────────────────────────────
  /// GET /api/kuis/{id}
  static Future<KuisModel?> getDetailKuis({
    required String token,
    required int kuisId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoint.detailKuis(kuisId)),
        headers: _headers(token),
      );
      final body = _decode(response.body);
      if (body['success'] != true) return null;

      final data = body['data'];
      final kuis = data['kuis'] ?? data;
      return KuisModel.fromJson(kuis);
    } catch (_) {
      return null;
    }
  }

  // ── 2. Mulai / resume sesi kuis ───────────────────────────────────────────
  /// POST /api/kuis/{id}/start
  /// Response: { id_hasil, waktu_mulai, batas_waktu }
  static Future<Map<String, dynamic>> startKuis({
    required String token,
    required int kuisId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoint.startKuis(kuisId)),
        headers: _headers(token),
      );
      final body = _decode(response.body);
      return {
        'success': body['success'] ?? false,
        'message': body['message'] ?? '',
        'data': body['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ── 3. Ambil soal ─────────────────────────────────────────────────────────
  /// GET /api/kuis/{id}/soal
  /// Response: { soal: [...], jawaban_tersimpan: {...}, batas_waktu }
  static Future<Map<String, dynamic>> getSoal({
    required String token,
    required int kuisId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoint.soalKuis(kuisId)),
        headers: _headers(token),
      );
      final body = _decode(response.body);
      if (body['success'] != true) {
        return {'success': false, 'message': body['message'] ?? ''};
      }

      final data = body['data'] as Map<String, dynamic>;

      // Parse soal
      final rawSoal = data['soal'] as List? ?? [];
      print("SOAL PERTAMA: ${jsonEncode(rawSoal.isNotEmpty ? rawSoal[0] : {})}");
      final soalList =
          rawSoal.map((s) => SoalModel.fromJson(s)).toList();

      // Parse jawaban tersimpan (untuk fitur resume)
      // Format dari API: { soal_id: { pilihan_id: ..., jawaban_essay: ... } }
      final rawJawabanRaw = data['jawaban_tersimpan'];
      final rawJawaban = (rawJawabanRaw is Map)
          ? Map<String, dynamic>.from(rawJawabanRaw)
          : <String, dynamic>{};
      final jawabanTersimpan = <int, dynamic>{};
      rawJawaban.forEach((soalId, val) {
        final id = int.tryParse(soalId) ?? 0;
        // Pilihan ganda → simpan pilihan_id (int)
        // Essay → simpan jawaban_essay (String)
        if (val['pilihan_id'] != null) {
          jawabanTersimpan[id] = val['pilihan_id'];
        } else if (val['jawaban_essay'] != null) {
          jawabanTersimpan[id] = val['jawaban_essay'];
        }
      });

      return {
        'success': true,
        'soalList': soalList,
        'jawabanTersimpan': jawabanTersimpan,
        'batasWaktu': data['batas_waktu'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil soal: $e'};
    }
  }

  // ── 4. Submit jawaban ─────────────────────────────────────────────────────
  /// POST /api/kuis/{id}/submit
  /// Body: { "jawaban": { soal_id: pilihan_id | teks_essay } }
  /// - Pilihan ganda → value: id_pilihan (int)
  /// - Essay         → value: teks jawaban (String)
  static Future<Map<String, dynamic>> submitJawaban({
    required String token,
    required int kuisId,
    required Map<int, dynamic> jawaban,
  }) async {
    try {
      // Konversi key int → String untuk JSON
      final jawabanStr =
          jawaban.map((k, v) => MapEntry(k.toString(), v));

      final response = await http.post(
        Uri.parse(ApiEndpoint.submitKuis(kuisId)),
        headers: _headers(token),
        body: jsonEncode({'jawaban': jawabanStr}),
      );
      final body = _decode(response.body);
      return {
        'success': body['success'] ?? false,
        'message': body['message'] ?? '',
        'data': body['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal submit: $e'};
    }
  }

  // ── 5. Hasil kuis ─────────────────────────────────────────────────────────
  /// GET /api/kuis/{id}/result
  static Future<Map<String, dynamic>> getHasil({
    required String token,
    required int kuisId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoint.resultKuis(kuisId)),
        headers: _headers(token),
      );
      final body = _decode(response.body);
      return {
        'success': body['success'] ?? false,
        'data': body['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil hasil: $e'};
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}