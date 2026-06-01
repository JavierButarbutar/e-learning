import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_pref.dart';
import '../data/models/presensi_model.dart';
import '../data/repositories/presensi_repository.dart';
import '../data/services/presensi_service.dart';

enum PresensiStatus { idle, loading, success, error }

class PresensiProvider extends ChangeNotifier {
  final PresensiRepository _repo;

  PresensiProvider({PresensiRepository? repository})
    : _repo = repository ?? PresensiRepository();

  Future<String> _getToken() async {
    final token = await SharedPref.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return token;
  }

  PresensiAktifModel? _selectedPresensi;

  PresensiAktifModel? get selectedPresensi => _selectedPresensi;

  void setSelectedPresensi(PresensiAktifModel presensi) {
    _selectedPresensi = presensi;
    notifyListeners();
  }

  PresensiStatus _activeStatus = PresensiStatus.idle;
  List<PresensiAktifModel> _presensiAktif = [];
  String? _activeError;

  PresensiStatus get activeStatus => _activeStatus;
  List<PresensiAktifModel> get presensiAktif =>
      List.unmodifiable(_presensiAktif);
  String? get activeError => _activeError;
  bool get isLoadingActive => _activeStatus == PresensiStatus.loading;

  PresensiStatus _scanStatus = PresensiStatus.idle;
  ScanResultModel? _scanResult;
  String? _scanError;
  bool _sudahAbsen = false;

  PresensiStatus get scanStatus => _scanStatus;
  ScanResultModel? get scanResult => _scanResult;
  String? get scanError => _scanError;
  bool get sudahAbsen => _sudahAbsen;
  bool get isLoadingScan => _scanStatus == PresensiStatus.loading;

  PresensiStatus _riwayatStatus = PresensiStatus.idle;
  List<RiwayatItemModel> _riwayat = [];
  PaginationModel? _pagination;
  String? _riwayatError;
  bool _isLoadingMore = false;

  String? _filterTanggalMulai;
  String? _filterTanggalSelesai;
  int? _filterMapelId;

  PresensiStatus get riwayatStatus => _riwayatStatus;
  List<RiwayatItemModel> get riwayat => List.unmodifiable(_riwayat);
  PaginationModel? get pagination => _pagination;
  String? get riwayatError => _riwayatError;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _pagination?.hasNextPage ?? false;

  PresensiStatus _rekapStatus = PresensiStatus.idle;
  RekapModel? _rekap;
  String? _rekapError;

  PresensiStatus get rekapStatus => _rekapStatus;
  RekapModel? get rekap => _rekap;
  String? get rekapError => _rekapError;
  bool get isLoadingRekap => _rekapStatus == PresensiStatus.loading;

  Future<void> fetchActivePresensi() async {
    _activeStatus = PresensiStatus.loading;
    _activeError = null;
    notifyListeners();

    try {
      final token = await _getToken();
      _presensiAktif = await _repo.getActivePresensi(token);
      _activeStatus = PresensiStatus.success;
    } on PresensiException catch (e) {
      _activeStatus = PresensiStatus.error;
      _activeError = e.message;
    } catch (e) {
      _activeStatus = PresensiStatus.error;
      _activeError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Gagal mengambil data presensi. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  Future<void> submitScan({
    required String qrCode,
    String? latitude,
    String? longitude,
  }) async {
    _scanStatus = PresensiStatus.loading;
    _scanError = null;
    _scanResult = null;
    _sudahAbsen = false;
    notifyListeners();

    try {
      final token = await _getToken();
      _scanResult = await _repo.scanQr(
        token: token,
        qrCode: qrCode,
        latitude: latitude,
        longitude: longitude,
      );
      _scanStatus = PresensiStatus.success;
    } on PresensiException catch (e) {
      _scanStatus = PresensiStatus.error;
      _scanError = e.message;

      if (e.isSudahAbsen) _sudahAbsen = true;
    } catch (e) {
      _scanStatus = PresensiStatus.error;
      _scanError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Gagal memproses scan. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  Future<void> fetchRiwayat({
    String? tanggalMulai,
    String? tanggalSelesai,
    int? mapelId,
  }) async {
    _filterTanggalMulai = tanggalMulai;
    _filterTanggalSelesai = tanggalSelesai;
    _filterMapelId = mapelId;

    _riwayatStatus = PresensiStatus.loading;
    _riwayatError = null;
    _riwayat = [];
    _pagination = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final result = await _repo.getRiwayat(
        token,
        tanggalMulai: _filterTanggalMulai,
        tanggalSelesai: _filterTanggalSelesai,
        mapelId: _filterMapelId,
        page: 1,
      );
      _riwayat = result.items;
      _pagination = result.pagination;
      _riwayatStatus = PresensiStatus.success;
    } on PresensiException catch (e) {
      _riwayatStatus = PresensiStatus.error;
      _riwayatError = e.message;
    } catch (e) {
      _riwayatStatus = PresensiStatus.error;
      _riwayatError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Gagal mengambil riwayat. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  Future<void> loadMoreRiwayat() async {
    if (_isLoadingMore || !hasNextPage) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final nextPage = (_pagination?.currentPage ?? 1) + 1;
      final result = await _repo.getRiwayat(
        token,
        tanggalMulai: _filterTanggalMulai,
        tanggalSelesai: _filterTanggalSelesai,
        mapelId: _filterMapelId,
        page: nextPage,
      );
      _riwayat = [..._riwayat, ...result.items];
      _pagination = result.pagination;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchRekap({int? bulan, int? tahun}) async {
    _rekapStatus = PresensiStatus.loading;
    _rekapError = null;
    notifyListeners();

    try {
      final token = await _getToken();
      _rekap = await _repo.getRekap(token, bulan: bulan, tahun: tahun);
      _rekapStatus = PresensiStatus.success;
    } on PresensiException catch (e) {
      _rekapStatus = PresensiStatus.error;
      _rekapError = e.message;
    } catch (e) {
      _rekapStatus = PresensiStatus.error;
      _rekapError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Gagal mengambil rekap. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  void resetScan() {
    _scanStatus = PresensiStatus.idle;
    _scanResult = null;
    _scanError = null;
    _sudahAbsen = false;
    notifyListeners();
  }

  void resetAll() {
    _activeStatus = PresensiStatus.idle;
    _presensiAktif = [];
    _activeError = null;

    _scanStatus = PresensiStatus.idle;
    _scanResult = null;
    _scanError = null;
    _sudahAbsen = false;

    _riwayatStatus = PresensiStatus.idle;
    _riwayat = [];
    _pagination = null;
    _riwayatError = null;
    _isLoadingMore = false;
    _filterTanggalMulai = null;
    _filterTanggalSelesai = null;
    _filterMapelId = null;

    _rekapStatus = PresensiStatus.idle;
    _rekap = null;
    _rekapError = null;

    notifyListeners();
  }
}
