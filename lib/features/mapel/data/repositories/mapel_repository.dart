import '../models/mapel_model.dart';
import '../services/mapel_service.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapelRepository {
  final MapelService _service = MapelService();

  Future<List<MapelModel>> getMapel() async {
    final token = await SharedPref.getToken();
    return await _service.getMapel(token ?? '');
  }

  Future<List<MateriItem>> getMateri(String idMapel) async {
    final token = await SharedPref.getToken();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    List<MateriItem> allMateri = [];

    final response = await http.get(
      Uri.parse(ApiEndpoint.materiByMapel(idMapel)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Kumpulkan semua id materi dulu
      final List<Map<String, dynamic>> allMateriRaw = [];
      for (var minggu in data['data']) {
        final materiList = minggu['materi'] as List;
        for (var m in materiList) {
          allMateriRaw.add(m);
        }
      }

      // FETCH SEMUA DETAIL SEKALIGUS (parallel), bukan satu per satu
      final detailFutures = allMateriRaw.map((m) async {
        final idMateri = m['id_materi'].toString();
        try {
          final detailRes = await http
              .get(
                Uri.parse(ApiEndpoint.detailMateri(idMateri)),
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));

          if (detailRes.statusCode == 200) {
            final detailData = jsonDecode(detailRes.body);
            return MateriItem.fromJson(detailData['data']);
          }
          return MateriItem.fromJson(m);
        } catch (_) {
          // Kalau detail gagal, pakai data ringkas dari list
          return MateriItem.fromJson(m);
        }
      });

      // Tunggu semua selesai bersamaan
      allMateri = await Future.wait(detailFutures);
    } else {
      throw Exception('Gagal mengambil materi');
    }

    // Fetch kuis juga parallel dengan materi sudah selesai
    try {
      final kuisRes = await http
          .get(Uri.parse(ApiEndpoint.kuis), headers: headers)
          .timeout(const Duration(seconds: 10));

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

          allMateri.add(
            MateriItem(
              id: k['id_kuis'].toString(),
              nomor: k['minggu_ke']?.toString() ?? '0',
              judul: k['judul_kuis'] ?? k['judul'] ?? 'Kuis',
              tanggal: k['tanggal_mulai'],
              type: MateriType.kuis,
              jumlahSoal: k['jumlah_soal'],
              durasiMenit: k['durasi_menit'],
              tipeKuis: TipeKuisMateriX.fromString(tipeKuisStr),
            ),
          );
        }
      }
    } catch (_) {}

    return allMateri;
  }
}
