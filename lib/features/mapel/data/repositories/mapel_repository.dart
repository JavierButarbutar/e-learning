import '../models/mapel_model.dart';
import '../services/mapel_service.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Bertanggung jawab sebagai perantara antara MapelProvider dan sumber data.
/// Provider tidak perlu tahu apakah data dari API atau cache lokal.
class MapelRepository {
  final MapelService _service = MapelService();

  // ── Ambil daftar mata pelajaran ───────────────────────────────────────────
  Future<List<MapelModel>> getMapel() async {
    final token = await SharedPref.getToken();
    return await _service.getMapel(token ?? '');
  }

  // ── Ambil materi + kuis berdasarkan id mapel ──────────────────────────────
  /// Menggabungkan materi (per minggu) dan kuis dalam satu list.
  Future<List<MateriItem>> getMateri(String idMapel) async {
    final token = await SharedPref.getToken();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    List<MateriItem> allMateri = [];

    // ── Step 1: Fetch list materi per minggu ──────────────────────────────
    final response = await http.get(
      Uri.parse(ApiEndpoint.materiByMapel(idMapel)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var minggu in data['data']) {
        final materiList = minggu['materi'] as List;

        for (var m in materiList) {
          final idMateri = m['id_materi'].toString();

          // Fetch detail per materi untuk dapat file_url, tugas, dll
          final detailRes = await http.get(
            Uri.parse(ApiEndpoint.detailMateri(idMateri)),
            headers: headers,
          );

          if (detailRes.statusCode == 200) {
            final detailData = jsonDecode(detailRes.body);
            allMateri.add(MateriItem.fromJson(detailData['data']));
          } else {
            allMateri.add(MateriItem.fromJson(m));
          }
        }
      }
    } else {
      throw Exception('Gagal mengambil materi');
    }

    // ── Step 2: Fetch kuis dan filter berdasarkan idMapel ────────────────
    final kuisRes = await http.get(
      Uri.parse(ApiEndpoint.kuis),
      headers: headers,
    );

    if (kuisRes.statusCode == 200) {
      final kuisData = jsonDecode(kuisRes.body);
      final kuisList = kuisData['data'] as List? ?? [];

      for (var k in kuisList) {
        final mapelId =
            k['mapel']?['id_mapel']?.toString() ??
            k['mapel_id']?.toString() ??
            k['id_mapel']?.toString() ??
            '';

        if (mapelId.isEmpty || mapelId != idMapel) continue;

        final tipeKuisStr =
            k['tipe_kuis']?.toString() ?? k['tipe']?.toString();

        allMateri.add(MateriItem(
          id: k['id_kuis'].toString(),
          nomor: k['minggu_ke']?.toString() ?? '0',
          judul: k['judul_kuis'] ?? k['judul'] ?? 'Kuis',
          tanggal: k['tanggal_mulai'],
          type: MateriType.kuis,
          jumlahSoal: k['jumlah_soal'],
          durasiMenit: k['durasi_menit'],
          tipeKuis: TipeKuisMateriX.fromString(tipeKuisStr),
        ));
      }
    }

    return allMateri;
  }
}