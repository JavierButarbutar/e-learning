import 'soal_model.dart';


class KuisModel {
  final int id;
  final String judulKuis;
  final String namaMapel;
  final String namaKelas;
  final TipeKuis tipeKuis;
  final int durasiMenit;
  final bool tampilkanNilai;
  final List<SoalModel> soalList;
  final int jumlahSoal;


  final bool? sudahDikerjakan;
  final double? nilaiAkhir;
  final String? statusPengerjaan;

  const KuisModel({
    required this.id,
    required this.judulKuis,
    required this.namaMapel,
    required this.namaKelas,
    required this.tipeKuis,
    required this.durasiMenit,
    this.tampilkanNilai = false,
    this.soalList = const [],
    this.jumlahSoal = 0,
    this.sudahDikerjakan,
    this.nilaiAkhir,
    this.statusPengerjaan,
  });


  factory KuisModel.fromJson(Map<String, dynamic> json) {
    final statusPengerjaan = json['status_pengerjaan'] as String?;
    final hasil = json['hasil'] as Map<String, dynamic>?;

    double? nilaiAkhir;
    final rawNilai = json['nilai_akhir'] ?? hasil?['nilai'];
    if (rawNilai != null) {
      nilaiAkhir = rawNilai is num
          ? rawNilai.toDouble()
          : double.tryParse(rawNilai.toString());
    }

    final tampilkanNilai = json['tampilkan_nilai'] as bool? ?? false;
    final sudah = statusPengerjaan == 'selesai' || statusPengerjaan == 'menunggu';


    final tipeRaw = (json['tipe_kuis'] ?? json['tipe']) as String?;



    final kelasObj = json['kelas'];
    final namaKelas = (kelasObj is Map ? kelasObj['nama_kelas'] : null)
        ?? json['nama_kelas']
        ?? '-';

    return KuisModel(
      id: json['id_kuis'] ?? 0,
      judulKuis: json['judul_kuis'] ?? '-',
      namaMapel: json['mapel']?['nama_mapel'] ?? json['nama_mapel'] ?? '-',
      namaKelas: namaKelas,
      tipeKuis: TipeKuisLabel.fromString(tipeRaw),
      durasiMenit: json['durasi_menit'] ?? 60,
      jumlahSoal: json['jumlah_soal'] as int? ?? 0,
      tampilkanNilai: tampilkanNilai,
      sudahDikerjakan: sudah,
      nilaiAkhir: nilaiAkhir,
      statusPengerjaan: statusPengerjaan,
    );
  }


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
      jumlahSoal: soal.length > 0 ? soal.length : jumlahSoal,
      sudahDikerjakan: sudahDikerjakan,
      nilaiAkhir: nilaiAkhir,
      statusPengerjaan: statusPengerjaan,
    );
  }


  KuisModel copyWithHasil({
    required bool sudahDikerjakan,
    double? nilaiAkhir,
    String? statusPengerjaan,
  }) {
    return KuisModel(
      id: id,
      judulKuis: judulKuis,
      namaMapel: namaMapel,
      namaKelas: namaKelas,
      tipeKuis: tipeKuis,
      durasiMenit: durasiMenit,
      tampilkanNilai: tampilkanNilai,
      soalList: soalList,
      jumlahSoal: jumlahSoal,
      sudahDikerjakan: sudahDikerjakan,
      nilaiAkhir: nilaiAkhir,
      statusPengerjaan: statusPengerjaan,
    );
  }
}


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


  int get sisaDetik {
    final diff = batasWaktu.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }
}