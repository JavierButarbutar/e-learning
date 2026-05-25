class JadwalItem {

  final String namaKelas;
  final String mataPelajaran;
  final String jamMulai;
  final String jamSelesai;
  final String hari;

  JadwalItem({
    required this.namaKelas,
    required this.mataPelajaran,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
  });

  factory JadwalItem.fromJson(
    Map<String, dynamic> json,
  ) {

    return JadwalItem(

      namaKelas:
          json['kelas']?.toString() ?? '-',

      mataPelajaran:
          json['mapel']?.toString() ?? '-',

      jamMulai:
          json['waktu_mulai']?.toString() ?? '00:00',

      jamSelesai:
          json['waktu_selesai']?.toString() ?? '00:00',

      hari:
          json['hari_label']?.toString() ?? '',
    );
  }

  // ===============================
  // JAM MULAI
  // ===============================

  DateTime get jamMulaiHariIni {

    final now = DateTime.now();

    final split = jamMulai.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(split[0]),
      int.parse(split[1]),
    );
  }

  // ===============================
  // JAM SELESAI
  // ===============================

  DateTime get jamSelesaiHariIni {

    final now = DateTime.now();

    final split = jamSelesai.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(split[0]),
      int.parse(split[1]),
    );
  }

  // ===============================
  // CEK SEDANG BERLANGSUNG
  // ===============================

  bool get sedangBerlangsung {

    final now = DateTime.now();

    return now.isAfter(jamMulaiHariIni) &&
        now.isBefore(jamSelesaiHariIni);
  }
}

// ===================================
// NAMA HARI
// ===================================

String namaHari(DateTime date) {

  switch (date.weekday) {

    case 1:
      return 'Senin';

    case 2:
      return 'Selasa';

    case 3:
      return 'Rabu';

    case 4:
      return 'Kamis';

    case 5:
      return 'Jumat';

    case 6:
      return 'Sabtu';

    default:
      return 'Minggu';
  }
}

// ===================================
// SINGKATAN HARI
// ===================================

String singkatanHari(String hari) {

  switch (hari) {

    case 'Senin':
      return 'Sen';

    case 'Selasa':
      return 'Sel';

    case 'Rabu':
      return 'Rab';

    case 'Kamis':
      return 'Kam';

    case 'Jumat':
      return 'Jum';

    case 'Sabtu':
      return 'Sab';

    default:
      return 'Min';
  }
}