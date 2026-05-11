// ─────────────────────────────────────────────────────────────
// PRESENSI MODEL
// Memetakan seluruh response dari PresensiApiController
// ─────────────────────────────────────────────────────────────

// ── Lokasi ───────────────────────────────────────────────────
class LokasiModel {
  final String nama;
  final double? latitude;
  final double? longitude;
  final double? radius;

  const LokasiModel({
    required this.nama,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) => LokasiModel(
        nama: json['nama'] as String? ?? '-',
        latitude: json['latitude'] != null
            ? double.tryParse(json['latitude'].toString())
            : null,
        longitude: json['longitude'] != null
            ? double.tryParse(json['longitude'].toString())
            : null,
        radius: json['radius'] != null
            ? double.tryParse(json['radius'].toString())
            : null,
      );
}

// ── Presensi Aktif ───────────────────────────────────────────
// Response: GET /api/presensi/active
class PresensiAktifModel {
  final int idPresensi;
  final String mapel;
  final String guru;
  final String kelas;
  final String? qrCode; // TAMBAHAN

  final LokasiModel lokasi;
  final String jamMulai;
  final String jamSelesai;
  final String batasTerlambat;
  final String faseWaktu;
  final int sisaWaktuMenit;
  final bool sudahAbsen;
  final String? statusKehadiran;
  final String? waktuPresensi;
  final String? keterangan;

  const PresensiAktifModel({
    required this.idPresensi,
    required this.mapel,
    required this.guru,
    required this.kelas,
    this.qrCode, // TAMBAHAN

    required this.lokasi,
    required this.jamMulai,
    required this.jamSelesai,
    required this.batasTerlambat,
    required this.faseWaktu,
    required this.sisaWaktuMenit,
    required this.sudahAbsen,
    this.statusKehadiran,
    this.waktuPresensi,
    this.keterangan,
  });

  factory PresensiAktifModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      PresensiAktifModel(
        idPresensi:
            (json['id_presensi'] as num?)?.toInt() ?? 0,

        mapel: json['mapel'] as String? ?? '-',

        guru: json['guru'] as String? ?? '-',

        kelas: json['kelas'] as String? ?? '-',

        // TAMBAHAN
        qrCode: json['qr_code'] as String?,

        lokasi: LokasiModel.fromJson(
          json['lokasi']
                  as Map<String, dynamic>? ??
              {},
        ),

        jamMulai:
            json['jam_mulai'] as String? ?? '-',

        jamSelesai:
            json['jam_selesai'] as String? ?? '-',

        batasTerlambat:
            json['batas_terlambat'] as String? ??
                '-',

        faseWaktu:
            json['fase_waktu'] as String? ??
                'normal',

        sisaWaktuMenit:
            (json['sisa_waktu_menit'] as num?)
                    ?.toInt() ??
                0,

        sudahAbsen:
            json['sudah_absen'] as bool? ??
                false,

        statusKehadiran:
            json['status_kehadiran'] as String?,

        waktuPresensi:
            json['waktu_presensi'] as String?,

        keterangan:
            json['keterangan'] as String?,
      );
}
// ── Hasil Scan QR ─────────────────────────────────────────────
// Response: POST /api/presensi/scan
class ScanResultModel {
  final String statusKehadiran; // 'hadir' | 'terlambat'
  final String waktuPresensi;
  final double? jarakMeter;
  final String mapel;
  final String kelas;

  const ScanResultModel({
    required this.statusKehadiran,
    required this.waktuPresensi,
    this.jarakMeter,
    required this.mapel,
    required this.kelas,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) =>
      ScanResultModel(
        statusKehadiran: json['status_kehadiran'] as String? ?? '-',
        waktuPresensi: json['waktu_presensi'] as String? ?? '-',
        jarakMeter: json['jarak_meter'] != null
            ? double.tryParse(json['jarak_meter'].toString())
            : null,
        mapel: json['mapel'] as String? ?? '-',
        kelas: json['kelas'] as String? ?? '-',
      );
}

// ── Riwayat Item ──────────────────────────────────────────────
// Response: GET /api/presensi/riwayat
class RiwayatItemModel {
  final int idDetail;
  final String? tanggal;
  final String mapel;
  final String guru;
  final String kelas;
  final String? jamMulai;
  final String? jamSelesai;
  final String? waktuPresensi;
  final String statusKehadiran; // 'hadir' | 'terlambat' | 'sakit' | 'izin' | 'alpha'
  final double? jarakMeter;
  final String? keterangan;

  const RiwayatItemModel({
    required this.idDetail,
    this.tanggal,
    required this.mapel,
    required this.guru,
    required this.kelas,
    this.jamMulai,
    this.jamSelesai,
    this.waktuPresensi,
    required this.statusKehadiran,
    this.jarakMeter,
    this.keterangan,
  });

  factory RiwayatItemModel.fromJson(Map<String, dynamic> json) =>
      RiwayatItemModel(
        idDetail: json['id_detail'] as int,
        tanggal: json['tanggal'] as String?,
        mapel: json['mapel'] as String? ?? '-',
        guru: json['guru'] as String? ?? '-',
        kelas: json['kelas'] as String? ?? '-',
        jamMulai: json['jam_mulai'] as String?,
        jamSelesai: json['jam_selesai'] as String?,
        waktuPresensi: json['waktu_presensi'] as String?,
        statusKehadiran: json['status_kehadiran'] as String? ?? '-',
        jarakMeter: json['jarak_meter'] != null
            ? double.tryParse(json['jarak_meter'].toString())
            : null,
        keterangan: json['keterangan'] as String?,
      );
}

// ── Pagination ────────────────────────────────────────────────
class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        currentPage: json['current_page'] as int? ?? 1,
        lastPage: json['last_page'] as int? ?? 1,
        perPage: json['per_page'] as int? ?? 20,
        total: json['total'] as int? ?? 0,
      );

  bool get hasNextPage => currentPage < lastPage;
}

// ── Rekap Statistik ───────────────────────────────────────────
// Response: GET /api/presensi/rekap
class RekapModel {
  final int total;
  final int hadir;
  final int terlambat;
  final int sakit;
  final int izin;
  final int alpha;
  final double persentaseKehadiran;

  const RekapModel({
    required this.total,
    required this.hadir,
    required this.terlambat,
    required this.sakit,
    required this.izin,
    required this.alpha,
    required this.persentaseKehadiran,
  });

  factory RekapModel.fromJson(Map<String, dynamic> json) => RekapModel(
        total: json['total'] as int? ?? 0,
        hadir: json['hadir'] as int? ?? 0,
        terlambat: json['terlambat'] as int? ?? 0,
        sakit: json['sakit'] as int? ?? 0,
        izin: json['izin'] as int? ?? 0,
        alpha: json['alpha'] as int? ?? 0,
        persentaseKehadiran:
            double.tryParse(json['persentase_kehadiran'].toString()) ?? 0.0,
      );
}