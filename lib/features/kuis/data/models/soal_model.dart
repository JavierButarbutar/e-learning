enum TipeSoal { pilihanGanda, esai }
 

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
    case 'kuis_harian':
    case 'harian_kuis':
    case 'harian':
    default:
      return TipeKuis.harianKuis;
  }
}
}
 

class PilihanModel {
  final int idPilihan;
  final String label;
  final String? teks;
  final String? gambarUrl;
 
  const PilihanModel({
    required this.idPilihan,
    required this.label,
    this.teks,
    this.gambarUrl,
  });
 
  factory PilihanModel.fromJson(Map<String, dynamic> json, int index) {
    return PilihanModel(
      idPilihan: json['id_pilihan'] ?? 0,
      label: String.fromCharCode(65 + index),
      teks: json['isi_pilihan'],
      gambarUrl: json['gambar_url'],
    );
  }
}
 

class SoalModel {
  final int idSoal;
  final int nomor;
  final String pertanyaan;
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
      pertanyaan: json['pertanyaan'] ?? '',
      tipe: tipe,
      gambarSoalUrl: json['gambar_url'] ?? json['gambar'],
      pilihan: pilihan,
    );
  }
}
 

class HasilKuisModel {
  final double? nilai;
  final bool tampilkanNilai;
  final bool menungguPenilaian;
 
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