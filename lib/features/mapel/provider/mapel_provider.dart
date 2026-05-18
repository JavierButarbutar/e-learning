import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/models/mapel_model.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/shared_pref.dart';

class MapelProvider extends ChangeNotifier {
  List<MapelModel> _mapel = [];
  List<MateriItem> _materi = [];

  bool _isLoading = false;
  String? _error;

  List<MapelModel> get mapel => _mapel;
  List<MateriItem> get materi => _materi;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // =========================
  // GET MAPEL
  // =========================

  Future<void> getMapel() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await SharedPref.getToken();

      final response = await http.get(
        Uri.parse(ApiEndpoint.mapel),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _mapel = (data['data'] as List)
            .map((e) => MapelModel.fromJson(e))
            .toList();
      } else {
        _error = 'Gagal mengambil data mapel';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // GET MATERI
  // =========================

  Future<void> getMateri(String idMapel) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await SharedPref.getToken();
      List<MateriItem> allMateri = [];

      // ── Step 1: Fetch list materi per minggu ──────────────────
      final response = await http.get(
        Uri.parse(ApiEndpoint.materiByMapel(idMapel)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        for (var minggu in data['data']) {
          final materiList = minggu['materi'] as List;

          for (var m in materiList) {
            final idMateri = m['id_materi'].toString();

            final detailRes = await http.get(
              Uri.parse(ApiEndpoint.detailMateri(idMateri)),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
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
        _error = 'Gagal mengambil materi';
      }

      // ── Step 2: Fetch kuis lalu filter berdasarkan mapel ──────
      final kuisRes = await http.get(
        Uri.parse(ApiEndpoint.kuis),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kuisRes.statusCode == 200) {
        final kuisData = jsonDecode(kuisRes.body);
        final kuisList = kuisData['data'] as List? ?? [];

        for (var k in kuisList) {
          // Backend pakai ->with(['mapel']), id_mapel ada di nested object
          final mapelId =
              k['mapel']?['id_mapel']?.toString() ?? // nested (paling mungkin)
              k['mapel_id']?.toString() ??            // flat langsung
              k['id_mapel']?.toString() ??            // flat alternatif
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

      _materi = allMateri;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}