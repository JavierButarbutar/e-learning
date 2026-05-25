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

  // Di mapel_provider.dart

  final Map<String, List<MateriItem>> _materiCache = {};
  Map<String, List<MateriItem>> get materiCache => _materiCache;

  Future<void> fetchAllMateri() async {
    if (_mapel.isEmpty) await getMapel(); // pastikan mapel sudah di-load

    final futures = _mapel.map((m) async {
      if (_materiCache.containsKey(m.id)) return; // skip kalau sudah di-cache
      try {
        final result = await _repo.getMateri(m.id);
        _materiCache[m.id] = result;
      } catch (_) {}
    });

    await Future.wait(futures);
    notifyListeners();
  }
  }