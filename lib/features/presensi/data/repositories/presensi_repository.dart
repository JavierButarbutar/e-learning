import '../models/presensi_model.dart';
import '../services/presensi_service.dart';

// ─────────────────────────────────────────────────────────────
// PRESENSI REPOSITORY
// Memanggil service → parse JSON → return model ke provider.
// Error dari service dibiarkan naik ke provider agar bisa
// ditangani di level UI.
// ─────────────────────────────────────────────────────────────
class PresensiRepository {
  final PresensiService _service;

  PresensiRepository({PresensiService? service})
      : _service = service ?? PresensiService();

  // ── Ambil presensi aktif hari ini ───────────────────────────
  Future<List<PresensiAktifModel>> getActivePresensi(String token) async {
    final response = await _service.getActivePresensi(token);

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => PresensiAktifModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Submit scan QR ──────────────────────────────────────────
  // Melempar PresensiException jika:
  //   409 → sudah absen
  //   422 → waktu habis atau di luar radius
  //   404 → QR tidak valid
  //   403 → bukan kelas siswa ini
  Future<ScanResultModel> scanQr({
    required String token,
    required String qrCode,
    String? latitude,
    String? longitude,
  }) async {
    final response = await _service.scanQr(
      token: token,
      qrCode: qrCode,
      latitude: latitude,
      longitude: longitude,
    );

    return ScanResultModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  // ── Ambil riwayat presensi (paginated) ──────────────────────
  Future<({List<RiwayatItemModel> items, PaginationModel pagination})>
      getRiwayat(
    String token, {
    String? tanggalMulai,
    String? tanggalSelesai,
    int? mapelId,
    int page = 1,
  }) async {
    final response = await _service.getRiwayat(
      token,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      mapelId: mapelId,
      page: page,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    final items = rawList
        .map((e) => RiwayatItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = PaginationModel.fromJson(
      response['pagination'] as Map<String, dynamic>? ?? {},
    );

    return (items: items, pagination: pagination);
  }

  // ── Ambil rekap statistik ────────────────────────────────────
  Future<RekapModel> getRekap(
    String token, {
    int? bulan,
    int? tahun,
  }) async {
    final response = await _service.getRekap(
      token,
      bulan: bulan,
      tahun: tahun,
    );

    return RekapModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}