import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/kuis_model.dart';
import '../models/soal_model.dart';

class KuisService {
  static Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

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
      if (body['success'] != true) {
        print('[KuisService] getDetailKuis failed: ${body['message']}');
        return null;
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};

      final Map<String, dynamic> kuisJson;
      if (data.containsKey('kuis') && data['kuis'] is Map) {
        final raw = Map<String, dynamic>.from(data['kuis'] as Map);

        if (!raw.containsKey('tipe_kuis') && raw.containsKey('tipe')) {
          raw['tipe_kuis'] = raw['tipe'];
        }

        kuisJson = {
          ...raw,
          'status_pengerjaan': data['status_pengerjaan'],
          'hasil': data['hasil'],
          'nilai_akhir': (data['hasil'] as Map?)?['nilai'],

          'jumlah_soal': data['jumlah_soal'],
          'nama_kelas': data['nama_kelas'],
        };
      } else {
        kuisJson = Map<String, dynamic>.from(data);
        if (!kuisJson.containsKey('tipe_kuis') &&
            kuisJson.containsKey('tipe')) {
          kuisJson['tipe_kuis'] = kuisJson['tipe'];
        }
      }

      print(
        '[KuisService] tipe_kuis: ${kuisJson['tipe_kuis']}, jumlah_soal: ${kuisJson['jumlah_soal']}, nama_kelas: ${kuisJson['nama_kelas']}',
      );
      return KuisModel.fromJson(kuisJson);
    } catch (e, st) {
      print('[KuisService] getDetailKuis exception: $e');
      print(st);
      return null;
    }
  }

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

      final rawSoal = data['soal'] as List? ?? [];
      final soalList = rawSoal.map((s) => SoalModel.fromJson(s)).toList();

      final rawJawabanRaw = data['jawaban_tersimpan'];
      final rawJawaban = (rawJawabanRaw is Map)
          ? Map<String, dynamic>.from(rawJawabanRaw)
          : <String, dynamic>{};
      final jawabanTersimpan = <int, dynamic>{};
      rawJawaban.forEach((soalId, val) {
        final id = int.tryParse(soalId.toString()) ?? 0;
        final valMap = val is Map ? val : {};
        if (valMap['pilihan_id'] != null) {
          jawabanTersimpan[id] = valMap['pilihan_id'];
        } else if (valMap['jawaban_essay'] != null) {
          jawabanTersimpan[id] = valMap['jawaban_essay'];
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

  static Future<Map<String, dynamic>> submitJawaban({
    required String token,
    required int kuisId,
    required Map<int, dynamic> jawaban,
  }) async {
    try {
      final jawabanStr = jawaban.map((k, v) => MapEntry(k.toString(), v));

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
      return {'success': body['success'] ?? false, 'data': body['data']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil hasil: $e'};
    }
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
