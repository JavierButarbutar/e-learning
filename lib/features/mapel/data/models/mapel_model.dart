import 'package:flutter/material.dart';

class MapelModel {
  final String id;
  final String nama;
  final String deskripsi;
  final int jumlahMateri;
  final int jumlahProyek;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<BagianMateri> bagian;

  const MapelModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.jumlahMateri,
    required this.jumlahProyek,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.bagian,
  });
}

class BagianMateri {
  final String judul;
  final List<MateriItem> items;
  const BagianMateri({required this.judul, required this.items});
}

enum MateriType { materi, tugas, kuis }

class MateriItem {
  final String nomor;
  final String judul;
  final String? tanggal;
  final MateriType type;
  final String? konten;

  // File yang diupload guru
  final String? namaFile;     // "Materi_IPAS_Bab1.pdf"
  final String? tipeFile;     // "pdf" | "word" | "ppt"
  final String? ukuranFile;   // "2.4 MB"
  final int? jumlahHalaman;  // jumlah halaman untuk simulasi PDF viewer

  // Khusus kuis
  final int? jumlahSoal;
  final int? durasiMenit;

  // Khusus tugas
  final String? deadlineTugas;

  const MateriItem({
    required this.nomor,
    required this.judul,
    this.tanggal,
    this.type = MateriType.materi,
    this.konten,
    this.namaFile,
    this.tipeFile,
    this.ukuranFile,
    this.jumlahHalaman,
    this.jumlahSoal,
    this.durasiMenit,
    this.deadlineTugas,
  });
}

// ── DUMMY DATA ────────────────────────────────────────────────
final List<MapelModel> dummyMapel = [
  MapelModel(
    id: 'ipas',
    nama: 'Ilmu Pengetahuan Alam dan Sosial',
    deskripsi: 'Sains Dasar & Fenomena Sosial',
    jumlahMateri: 12, jumlahProyek: 4,
    icon: Icons.science_outlined,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF2E7D32),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Pengenalan', items: [
        MateriItem(
          nomor: '01', judul: 'Apa itu IPAS?',
          namaFile: 'Materi_01_Apa_itu_IPAS.pdf',
          tipeFile: 'pdf', ukuranFile: '1.2 MB', jumlahHalaman: 8,
          konten: _dummyPdfText,
        ),
        MateriItem(
          nomor: '02', judul: 'Mengapa harus belajar IPAS?',
          tanggal: '21-01-2026',
          namaFile: 'Materi_02_Belajar_IPAS.pdf',
          tipeFile: 'pdf', ukuranFile: '980 KB', jumlahHalaman: 6,
          konten: _dummyPdfText,
        ),
      ]),
      BagianMateri(judul: 'Bagian 02 - Biologi', items: [
        MateriItem(
          nomor: '03', judul: 'Sel dan Jaringan Makhluk Hidup',
          tanggal: '28-01-2026',
          type: MateriType.tugas,
          namaFile: 'Materi_03_Sel_Jaringan.pdf',
          tipeFile: 'pdf', ukuranFile: '3.1 MB', jumlahHalaman: 14,
          konten: _dummyPdfText,
          deadlineTugas: '04 Feb 2026, 23:59',
        ),
        MateriItem(
          nomor: '04', judul: 'Organ Reproduksi Manusia',
          tanggal: '04-02-2026',
          namaFile: 'Materi_04_Organ_Reproduksi.pdf',
          tipeFile: 'pdf', ukuranFile: '2.4 MB', jumlahHalaman: 12,
          konten: _dummyPdfText,
        ),
      ]),
      BagianMateri(judul: 'Bagian 03 - Kimia', items: [
        MateriItem(
          nomor: '05', judul: 'Atom dan Molekul',
          type: MateriType.kuis,
          namaFile: 'Materi_05_Atom_Molekul.pdf',
          tipeFile: 'pdf', ukuranFile: '1.8 MB', jumlahHalaman: 10,
          konten: _dummyPdfText,
          jumlahSoal: 15, durasiMenit: 15,
        ),
      ]),
    ],
  ),
  MapelModel(
    id: 'mtk',
    nama: 'Matematika',
    deskripsi: 'Logika dan Perhitungan',
    jumlahMateri: 8, jumlahProyek: 2,
    icon: Icons.calculate_outlined,
    iconBg: const Color(0xFFE3F2FD),
    iconColor: const Color(0xFF1E88E5),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Aljabar', items: [
        MateriItem(
          nomor: '01', judul: 'Persamaan Linear',
          tanggal: '15-01-2026',
          namaFile: 'Materi_Persamaan_Linear.pdf',
          tipeFile: 'pdf', ukuranFile: '1.5 MB', jumlahHalaman: 9,
          konten: _dummyPdfText,
        ),
        MateriItem(
          nomor: '02', judul: 'Persamaan Kuadrat',
          type: MateriType.kuis,
          namaFile: 'Materi_Persamaan_Kuadrat.pdf',
          tipeFile: 'pdf', ukuranFile: '2.0 MB', jumlahHalaman: 11,
          konten: _dummyPdfText,
          jumlahSoal: 10, durasiMenit: 20,
        ),
      ]),
      BagianMateri(judul: 'Bagian 02 - Geometri', items: [
        MateriItem(
          nomor: '03', judul: 'Luas dan Keliling Bangun Datar',
          tanggal: '22-01-2026',
          type: MateriType.tugas,
          namaFile: 'Materi_Bangun_Datar.pdf',
          tipeFile: 'pdf', ukuranFile: '2.2 MB', jumlahHalaman: 10,
          konten: _dummyPdfText,
          deadlineTugas: '29 Jan 2026, 23:59',
        ),
      ]),
    ],
  ),
  MapelModel(
    id: 'bind',
    nama: 'Bahasa Indonesia',
    deskripsi: 'Bahasa dan Sastra Indonesia',
    jumlahMateri: 10, jumlahProyek: 3,
    icon: Icons.book_outlined,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFF5A623),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Teks', items: [
        MateriItem(
          nomor: '01', judul: 'Teks Deskripsi',
          tanggal: '10-01-2026',
          namaFile: 'Materi_Teks_Deskripsi.pdf',
          tipeFile: 'pdf', ukuranFile: '1.1 MB', jumlahHalaman: 7,
          konten: _dummyPdfText,
        ),
        MateriItem(
          nomor: '02', judul: 'Teks Narasi',
          tanggal: '17-01-2026',
          type: MateriType.tugas,
          namaFile: 'Materi_Teks_Narasi.pdf',
          tipeFile: 'pdf', ukuranFile: '900 KB', jumlahHalaman: 5,
          konten: _dummyPdfText,
          deadlineTugas: '24 Jan 2026, 23:59',
        ),
      ]),
    ],
  ),
  MapelModel(
    id: 'bing',
    nama: 'Bahasa Inggris',
    deskripsi: 'English Language Skills',
    jumlahMateri: 15, jumlahProyek: 5,
    icon: Icons.language_outlined,
    iconBg: const Color(0xFFFCE4EC),
    iconColor: const Color(0xFFE91E63),
    bagian: [
      BagianMateri(judul: 'Chapter 01 - Greetings', items: [
        MateriItem(
          nomor: '01', judul: 'Introduction & Greetings',
          namaFile: 'Chapter01_Greetings.pdf',
          tipeFile: 'pdf', ukuranFile: '800 KB', jumlahHalaman: 6,
          konten: _dummyPdfText,
        ),
        MateriItem(
          nomor: '02', judul: 'Daily Conversation',
          type: MateriType.kuis,
          namaFile: 'Chapter02_Conversation.pdf',
          tipeFile: 'pdf', ukuranFile: '1.3 MB', jumlahHalaman: 8,
          konten: _dummyPdfText,
          jumlahSoal: 12, durasiMenit: 15,
        ),
      ]),
    ],
  ),
  MapelModel(
    id: 'ppkn',
    nama: 'Pendidikan Pancasila',
    deskripsi: 'Nilai dan Norma Bangsa',
    jumlahMateri: 6, jumlahProyek: 1,
    icon: Icons.account_balance_outlined,
    iconBg: const Color(0xFFEDE7F6),
    iconColor: const Color(0xFF7B1FA2),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Pancasila', items: [
        MateriItem(
          nomor: '01', judul: 'Sejarah Pancasila',
          namaFile: 'Materi_Sejarah_Pancasila.pdf',
          tipeFile: 'pdf', ukuranFile: '1.6 MB', jumlahHalaman: 10,
          konten: _dummyPdfText,
        ),
        MateriItem(
          nomor: '02', judul: 'Nilai-nilai Pancasila',
          type: MateriType.tugas,
          namaFile: 'Materi_Nilai_Pancasila.pdf',
          tipeFile: 'pdf', ukuranFile: '1.4 MB', jumlahHalaman: 8,
          konten: _dummyPdfText,
          deadlineTugas: '31 Jan 2026, 23:59',
        ),
      ]),
    ],
  ),
];

// Dummy teks panjang untuk simulasi isi PDF
const _dummyPdfText = '''
Sistem Informasi Manajemen Siswa (SIMANS) adalah salah satu contoh penerapan teknologi informasi di dunia pendidikan. Sistem informasi ini merupakan sistem yang dirancang untuk membantu pencatatan dan pengelolaan data siswa di Sekolah Dasar Islam (SDI) Taman An-Nahl Sekarejo. Sistem informasi berbasis web ini penting diterapkan untuk memberikan nilai tambah bagi SDI Taman An-Nahl terhadap pelayanan digital baik pengelolaan database siswa, pencatatan atau pelaporan aktivitas siswa kepada orang tua.

Pengembangan yang digunakan pada Sistem Informasi Manajemen Siswa (SIMANS) ini adalah metode prototyping dengan pengujian kualitas perangkat lunak menggunakan metode black-box testing dan white-box testing. White-box testing adalah suatu metode pengujian sistem dengan cara menganalisis apakah ada yang salah atau tidak pada kode suatu program.

Pengujian ini sangat penting dilakukan sebelum sistem dijalankan, hal ini berfungsi untuk menguji kelayakan dari sistem tersebut. Perangkat lunak memberikan kemudahan, pengolahan dan pengelolaan data serta menjamin kualitas sistem.

Setelah dibuatnya sistem informasi ini, diharapkan dapat membantu organisasi mengelola aktivitas akademik di SDI Taman An-Nahl dengan baik dan efisien. Bukan hanya itu, dengan adanya sistem ini data-data siswa dapat terkiim dengan baik, serta dapat meningkatkan pelayanan laporan akademik dan aktivitas siswa kepada orang tua / wali melalui Sistem Informasi Manajemen Siswa (SIMANS).

2. METODOLOGI

Dalam melakukan perancangan Sistem informasi Manajemen Siswa (SIMANS) berbasis web setelah ditetapkan terdapat beberapa tahapan yang harus dilakukan. Adapun tahapan-tahapan yang dilakukan dapat dilihat pada Gambar 1.

2.1 Analisis Kebutuhan Sistem

Langkah awal dalam melakukan penelitian ini adalah analisis kebutuhan sistem. Dalam analisis kebutuhan sistem terdapat dua hal yang harus dianalisis, yaitu analisis kebutuhan fungsional dan analisis kebutuhan nonfungsional.
''';