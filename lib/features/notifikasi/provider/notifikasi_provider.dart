import 'package:flutter/material.dart';
import '../data/models/notifikasi_model.dart';
import '../data/repositories/notifikasi_repository.dart';

class NotifikasiProvider extends ChangeNotifier {
  List<NotifikasiModel> _list = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<NotifikasiModel> get list => _list;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadNotifikasi({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _list = [];
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await NotifikasiRepository.getNotifikasi(
        page: _currentPage,
      );

      final newData = result['data'] as List<NotifikasiModel>;
      final pagination = result['pagination'];

      _list.addAll(newData);
      _unreadCount = result['unread_count'] ?? 0;
      _currentPage++;

      if (_currentPage > (pagination['last_page'] ?? 1)) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bacaNotifikasi(int id) async {
    await NotifikasiRepository.bacaNotifikasi(id);
    final idx = _list.indexWhere((n) => n.idNotifikasi == id);
    if (idx != -1 && !_list[idx].isRead) {
      _list[idx] = NotifikasiModel(
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
    await NotifikasiRepository.bacaSemua();
    _list = _list
        .map(
          (n) => NotifikasiModel(
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

  Future<void> refreshUnreadCount() async {
    _unreadCount = await NotifikasiRepository.getUnreadCount();
    notifyListeners();
  }
}
