import '../models/presensi_model.dart';
import '../services/presensi_service.dart';

class PresensiRepository {
  final PresensiService _service;

  PresensiRepository({PresensiService? service})
    : _service = service ?? PresensiService();

  Future<List<PresensiAktifModel>> getActivePresensi(String token) async {
    final response = await _service.getActivePresensi(token);

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => PresensiAktifModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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

    return ScanResultModel.fromJson(response['data'] as Map<String, dynamic>);
  }

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

  Future<RekapModel> getRekap(String token, {int? bulan, int? tahun}) async {
    final response = await _service.getRekap(token, bulan: bulan, tahun: tahun);

    return RekapModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
