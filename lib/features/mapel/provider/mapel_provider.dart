import 'package:flutter/material.dart';
import '../data/models/mapel_model.dart';
import '../data/repositories/mapel_repository.dart';

class MapelProvider extends ChangeNotifier {
  final _repo = MapelRepository();

  List<MapelModel> _mapel = [];
  List<MateriItem> _materi = [];
  bool _isLoading = false;
  String? _error;

  List<MapelModel> get mapel => _mapel;
  List<MateriItem> get materi => _materi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Ambil daftar mapel ────────────────────────────────────────────────────
  Future<void> getMapel() async {
    _setLoading(true);
    try {
      _mapel = await _repo.getMapel();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Ambil materi + kuis berdasarkan id mapel ──────────────────────────────
  Future<void> getMateri(String idMapel) async {
    _setLoading(true);
    try {
      _materi = await _repo.getMateri(idMapel);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}