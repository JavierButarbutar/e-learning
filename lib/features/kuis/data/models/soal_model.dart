// ── Tipe soal ────────────────────────────────────────────────────────────────
enum TipeSoal { pilihanGanda, esai }
 
// ── Tipe kuis ────────────────────────────────────────────────────────────────
enum TipeKuis { harianKuis, uts, uas }
 
extension TipeKuisLabel on TipeKuis {
  String get label {
    switch (this) {
      case TipeKuis.harianKuis:
        return 'Kuis Harian';
      case TipeKuis.uts:
        return 'UTS';
      case TipeKuis.uas:
        return 'UAS';
    }
  }
 
  static TipeKuis fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'uts':
        return TipeKuis.uts;
      case 'uas':
        return TipeKuis.uas;
      default:
        return TipeKuis.harianKuis;
    }
  }
}
 
// ── Model pilihan jawaban ─────────────────────────────────────────────────────
class PilihanModel {
  final int idPilihan;      // id_pilihan dari API — dikirim saat submit
  final String label;       // 'A', 'B', 'C', 'D' — generate di client
  final String? teks;       // isi_pilihan dari API
  final String? gambarUrl;  // gambar_url dari API (opsional)
 
  const PilihanModel({
    required this.idPilihan,
    required this.label,
    this.teks,
    this.gambarUrl,
  });
 
  factory PilihanModel.fromJson(Map<String, dynamic> json, int index) {
    return PilihanModel(
      idPilihan: json['id_pilihan'] ?? 0,
      label: String.fromCharCode(65 + index), // 0→A, 1→B, 2→C, 3→D
      teks: json['isi_pilihan'],
      gambarUrl: json['gambar_url'], // sudah full URL dari backend
    );
  }
}
 
// ── Model soal ────────────────────────────────────────────────────────────────
class SoalModel {
  final int idSoal;           // id_soal dari API — key untuk submit jawaban
  final int nomor;            // nomor_urut dari API
  final String pertanyaan;    // isi_soal dari API
  final TipeSoal tipe;
  final String? gambarSoalUrl;
  final List<PilihanModel>? pilihan;
 
  const SoalModel({
    required this.idSoal,
    required this.nomor,
    required this.pertanyaan,
    required this.tipe,
    this.gambarSoalUrl,
    this.pilihan,
  });
 
    factory SoalModel.fromJson(Map<String, dynamic> json) {
    final tipe = json['tipe_soal'] == 'essay'
        ? TipeSoal.esai
        : TipeSoal.pilihanGanda;

    List<PilihanModel>? pilihan;
    if (tipe == TipeSoal.pilihanGanda) {
      final rawPilihan = json['pilihan_jawaban'] as List? ?? [];
      pilihan = rawPilihan
          .asMap()
          .entries
          .map((e) => PilihanModel.fromJson(e.value, e.key))
          .toList();
    }

    return SoalModel(
      idSoal: json['id_soal'] ?? 0,
      nomor: json['nomor_urut'] ?? 0,
      pertanyaan: json['pertanyaan'] ?? '',  // ← fix: isi_soal → pertanyaan
      tipe: tipe,
      gambarSoalUrl: json['gambar'],         // ← fix: gambar_url → gambar
      pilihan: pilihan,
    );
  }
}
 
// ── Model hasil submit ────────────────────────────────────────────────────────
class HasilKuisModel {
  final double? nilai;
  final bool tampilkanNilai;
  final bool menungguPenilaian; // true jika ada soal essay
 
  const HasilKuisModel({
    this.nilai,
    required this.tampilkanNilai,
    required this.menungguPenilaian,
  });
 
  factory HasilKuisModel.fromJson(Map<String, dynamic> json) {
    return HasilKuisModel(
      nilai: (json['nilai'] as num?)?.toDouble(),
      tampilkanNilai: json['tampilkan_nilai'] ?? false,
      menungguPenilaian: json['menunggu_penilaian'] ?? false,
    );
  }
}