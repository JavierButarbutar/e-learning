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

      print("STATUS MAPEL: ${response.statusCode}");
      print("BODY MAPEL: ${response.body}");

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

    // Step 1: ambil list materi
    final response = await http.get(
      Uri.parse(ApiEndpoint.materiByMapel(idMapel)),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<MateriItem> allMateri = [];

      for (var minggu in data['data']) {
        final materiList = minggu['materi'] as List;

        // Step 2: untuk tiap materi, fetch detail-nya agar dapat field 'tugas'
        for (var m in materiList) {
          final idMateri = m['id_materi'].toString();

          final detailRes = await http.get(
            Uri.parse(ApiEndpoint.detailMateri(idMateri)), // GET /api/materi/{id}
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (detailRes.statusCode == 200) {
            final detailData = jsonDecode(detailRes.body);
            allMateri.add(MateriItem.fromJson(detailData['data']));
          } else {
            // Fallback: pakai data list tanpa info tugas
            allMateri.add(MateriItem.fromJson(m));
          }
        }
      }

      _materi = allMateri;
    } else {
      _error = 'Gagal mengambil materi';
    }
  } catch (e) {
    _error = e.toString();
  }

  _isLoading = false;
  notifyListeners();
}}