import 'package:flutter/material.dart';
import '../data/models/notifikasi_guru_model.dart';
import '../data/repositories/notifikasi_guru_repository.dart';

class NotifikasiGuruProvider extends ChangeNotifier {
  List<NotifikasiGuruModel> _list = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false; // TAMBAHAN
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<NotifikasiGuruModel> get list => _list;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore; // TAMBAHAN
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadNotifikasi({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _list = [];
    }

    if (_isLoading || _isLoadingMore || !_hasMore) return;

    // Bedakan loading pertama vs load more
    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final result = await NotifikasiGuruRepository.getNotifikasi(
        page: _currentPage,
      );

      final newData = result['data'] as List<NotifikasiGuruModel>;
      final pagination = result['pagination'];

      _list.addAll(newData);
      _unreadCount = result['unread_count'] ?? 0;
      _currentPage++;

      if (_currentPage > (pagination?['last_page'] ?? 1)) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> bacaNotifikasi(int id) async {
    await NotifikasiGuruRepository.bacaNotifikasi(id);
    final idx = _list.indexWhere((n) => n.idNotifikasi == id);
    if (idx != -1 && !_list[idx].isRead) {
      _list[idx] = NotifikasiGuruModel(
        idNotifikasi: _list[idx].idNotifikasi,
        tipe: _list[idx].tipe,
        judul: _list[idx].judul,
        isi: _list[idx].isi,
        data: _list[idx].data,
        isRead: true,
        createdAt: _list[idx].createdAt,
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> bacaSemua() async {
    await NotifikasiGuruRepository.bacaSemua();
    _list = _list
        .map(
          (n) => NotifikasiGuruModel(
            idNotifikasi: n.idNotifikasi,
            tipe: n.tipe,
            judul: n.judul,
            isi: n.isi,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          ),
        )
        .toList();
    _unreadCount = 0;
    notifyListeners();
  }

  // Dipanggil FCM push saat foreground, tanpa hit API
  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  // Dipanggil hanya saat buka halaman, BUKAN polling
  Future<void> refreshUnreadCount() async {
    try {
      // Guru pakai endpoint yang sama, ambil dari unread_count response
      final result = await NotifikasiGuruRepository.getNotifikasi(page: 1);
      _unreadCount = result['unread_count'] ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('refreshUnreadCount guru error: $e');
    }
  }
}