import 'soal_model.dart';

// ── Model kuis ────────────────────────────────────────────────────────────────
class KuisModel {
  final int id;
  final String judulKuis;
  final String namaMapel;
  final String namaKelas;
  final TipeKuis tipeKuis;
  final int durasiMenit;
  final bool tampilkanNilai;
  final List<SoalModel> soalList; // diisi setelah getSoal()

  const KuisModel({
    required this.id,
    required this.judulKuis,
    required this.namaMapel,
    required this.namaKelas,
    required this.tipeKuis,
    required this.durasiMenit,
    this.tampilkanNilai = false,
    this.soalList = const [],
  });

  /// Parse dari response show() — belum ada soal
  factory KuisModel.fromJson(Map<String, dynamic> json) {
    return KuisModel(
      id: json['id_kuis'] ?? 0,
      judulKuis: json['judul_kuis'] ?? '-',
      namaMapel: json['mapel']?['nama_mapel'] ?? '-',
      namaKelas: json['kelas']?['nama_kelas'] ?? '-',
      tipeKuis: TipeKuisLabel.fromString(json['tipe_kuis']),
      durasiMenit: json['durasi_menit'] ?? 60,
      tampilkanNilai: json['tampilkan_nilai'] ?? false,
    );
  }

  /// Buat salinan dengan soal yang sudah diisi
  KuisModel copyWithSoal(List<SoalModel> soal) {
    return KuisModel(
      id: id,
      judulKuis: judulKuis,
      namaMapel: namaMapel,
      namaKelas: namaKelas,
      tipeKuis: tipeKuis,
      durasiMenit: durasiMenit,
      tampilkanNilai: tampilkanNilai,
      soalList: soal,
    );
  }
}

// ── Model sesi kuis (response dari start()) ───────────────────────────────────
class SesiKuisModel {
  final int idHasil;
  final DateTime waktuMulai;
  final DateTime batasWaktu;

  const SesiKuisModel({
    required this.idHasil,
    required this.waktuMulai,
    required this.batasWaktu,
  });

  factory SesiKuisModel.fromJson(Map<String, dynamic> json) {
    return SesiKuisModel(
      idHasil: json['id_hasil'] ?? 0,
      waktuMulai: DateTime.parse(json['waktu_mulai']),
      batasWaktu: DateTime.parse(json['batas_waktu']),
    );
  }

  /// Sisa detik dari sekarang sampai batas waktu
  int get sisaDetik {
    final diff = batasWaktu.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }
}