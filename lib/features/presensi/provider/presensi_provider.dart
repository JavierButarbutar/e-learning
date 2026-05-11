import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_pref.dart'; // sesuaikan path SharedPref milikmu
import '../data/models/presensi_model.dart';
import '../data/repositories/presensi_repository.dart';
import '../data/services/presensi_service.dart';

// ─────────────────────────────────────────────────────────────
// STATE ENUM
// ─────────────────────────────────────────────────────────────
enum PresensiStatus { idle, loading, success, error }

// ─────────────────────────────────────────────────────────────
// PRESENSI PROVIDER
//
// Token diambil otomatis dari SharedPreferences — tidak perlu
// dipass manual dari widget.
//
// Contoh pemakaian:
//   await context.read<PresensiProvider>().fetchActivePresensi();
//   context.watch<PresensiProvider>().presensiAktif;
// ─────────────────────────────────────────────────────────────
class PresensiProvider extends ChangeNotifier {
  final PresensiRepository _repo;
  
  PresensiProvider({PresensiRepository? repository})
      : _repo = repository ?? PresensiRepository();

  // ────────────────────────────────────────────────────────────
  // HELPER: ambil token dari SharedPreferences
  // ────────────────────────────────────────────────────────────
  Future<String> _getToken() async {
    final token = await SharedPref.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return token;
  }

  PresensiAktifModel? _selectedPresensi;

PresensiAktifModel? get selectedPresensi =>
    _selectedPresensi;

void setSelectedPresensi(
  PresensiAktifModel presensi,
) {
  _selectedPresensi = presensi;
  notifyListeners();
}
  // ────────────────────────────────────────────────────────────
  // STATE: PRESENSI AKTIF
  // ────────────────────────────────────────────────────────────
  PresensiStatus _activeStatus = PresensiStatus.idle;
  List<PresensiAktifModel> _presensiAktif = [];
  String? _activeError;

  PresensiStatus get activeStatus => _activeStatus;
  List<PresensiAktifModel> get presensiAktif => List.unmodifiable(_presensiAktif);
  String? get activeError => _activeError;
  bool get isLoadingActive => _activeStatus == PresensiStatus.loading;

  // ────────────────────────────────────────────────────────────
  // STATE: SCAN QR
  // ────────────────────────────────────────────────────────────
  PresensiStatus _scanStatus = PresensiStatus.idle;
  ScanResultModel? _scanResult;
  String? _scanError;
  bool _sudahAbsen = false;

  PresensiStatus get scanStatus => _scanStatus;
  ScanResultModel? get scanResult => _scanResult;
  String? get scanError => _scanError;
  bool get sudahAbsen => _sudahAbsen;
  bool get isLoadingScan => _scanStatus == PresensiStatus.loading;

  // ────────────────────────────────────────────────────────────
  // STATE: RIWAYAT
  // ────────────────────────────────────────────────────────────
  PresensiStatus _riwayatStatus = PresensiStatus.idle;
  List<RiwayatItemModel> _riwayat = [];
  PaginationModel? _pagination;
  String? _riwayatError;
  bool _isLoadingMore = false;

  // Filter riwayat disimpan di state agar loadMore konsisten
  String? _filterTanggalMulai;
  String? _filterTanggalSelesai;
  int? _filterMapelId;

  PresensiStatus get riwayatStatus => _riwayatStatus;
  List<RiwayatItemModel> get riwayat => List.unmodifiable(_riwayat);
  PaginationModel? get pagination => _pagination;
  String? get riwayatError => _riwayatError;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _pagination?.hasNextPage ?? false;

  // ────────────────────────────────────────────────────────────
  // STATE: REKAP
  // ────────────────────────────────────────────────────────────
  PresensiStatus _rekapStatus = PresensiStatus.idle;
  RekapModel? _rekap;
  String? _rekapError;

  PresensiStatus get rekapStatus => _rekapStatus;
  RekapModel? get rekap => _rekap;
  String? get rekapError => _rekapError;
  bool get isLoadingRekap => _rekapStatus == PresensiStatus.loading;

  // ────────────────────────────────────────────────────────────
  // METHODS
  // ────────────────────────────────────────────────────────────

  /// Fetch presensi aktif hari ini untuk kelas siswa.
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

  /// Submit scan QR code.
  /// [latitude] dan [longitude] opsional (String karena dikirim ke API sebagai string).
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
      // Tandai jika siswa memang sudah absen (HTTP 409)
      if (e.isSudahAbsen) _sudahAbsen = true;
    } catch (e) {
      _scanStatus = PresensiStatus.error;
      _scanError = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Gagal memproses scan. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  /// Fetch riwayat halaman pertama (atau refresh).
  /// Filter yang dipass disimpan di state sehingga [loadMoreRiwayat]
  /// tidak perlu menerima parameter filter ulang.
  Future<void> fetchRiwayat({
    String? tanggalMulai,
    String? tanggalSelesai,
    int? mapelId,
  }) async {
    // Simpan filter ke state
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

  /// Load halaman berikutnya dari riwayat (infinite scroll).
  /// Filter diambil dari state — tidak perlu dipass dari widget.
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
    } catch (_) {
      // Silent fail — list lama tetap tampil, user bisa scroll lagi
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Fetch rekap statistik kehadiran.
  /// [bulan] dan [tahun] opsional; jika tidak diisi, API return semua data.
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

  // ────────────────────────────────────────────────────────────
  // RESET HELPERS
  // ────────────────────────────────────────────────────────────

  /// Reset state scan sebelum scan ulang.
  void resetScan() {
    _scanStatus = PresensiStatus.idle;
    _scanResult = null;
    _scanError = null;
    _sudahAbsen = false;
    notifyListeners();
  }

  /// Reset semua state (misal saat logout).
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