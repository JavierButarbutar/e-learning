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

  const MateriItem({
    required this.nomor,
    required this.judul,
    this.tanggal,
    this.type = MateriType.materi,
    this.konten,
  });
}

// ── DUMMY DATA ────────────────────────────────────────────────
final List<MapelModel> dummyMapel = [
  MapelModel(
    id: 'ipas',
    nama: 'Ilmu Pengetahuan Alam dan Sosial',
    deskripsi: 'Sains Dasar & Fenomena Sosial',
    jumlahMateri: 12,
    jumlahProyek: 4,
    icon: Icons.science_outlined,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF2E7D32),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Pengenalan', items: [
        MateriItem(nomor: '01', judul: 'Apa itu IPAS?',
            konten: 'IPAS adalah singkatan dari Ilmu Pengetahuan Alam dan Sosial. Mata pelajaran ini menggabungkan konsep sains dan ilmu sosial untuk memberikan pemahaman menyeluruh tentang alam dan masyarakat.'),
        MateriItem(nomor: '02', judul: 'Mengapa harus belajar IPAS?', tanggal: '21-01-2026',
            konten: 'Belajar IPAS penting untuk memahami fenomena alam dan sosial di sekitar kita, mengembangkan kemampuan berpikir kritis, dan mempersiapkan diri untuk kehidupan di masyarakat.'),
      ]),
      BagianMateri(judul: 'Bagian 02 - Biologi', items: [
        MateriItem(nomor: '03', judul: 'Sel dan Jaringan Makhluk Hidup', tanggal: '28-01-2026', type: MateriType.tugas,
            konten: 'Sel adalah unit terkecil kehidupan. Setiap makhluk hidup tersusun dari sel-sel yang membentuk jaringan, organ, dan sistem organ.'),
        MateriItem(nomor: '04', judul: 'Organ Reproduksi Manusia', tanggal: '04-02-2026',
            konten: 'Sistem reproduksi manusia terdiri dari organ-organ yang berfungsi untuk perkembangbiakan. Pada pria terdapat testis dan penis, sedangkan pada wanita terdapat ovarium dan rahim.'),
      ]),
      BagianMateri(judul: 'Bagian 03 - Kimia', items: [
        MateriItem(nomor: '05', judul: 'Atom dan Molekul', type: MateriType.kuis,
            konten: 'Atom adalah partikel terkecil dari suatu unsur yang masih memiliki sifat unsur tersebut. Molekul adalah gabungan dua atom atau lebih.'),
      ]),
    ],
  ),
  MapelModel(
    id: 'mtk',
    nama: 'Matematika',
    deskripsi: 'Logika dan Perhitungan',
    jumlahMateri: 8,
    jumlahProyek: 2,
    icon: Icons.calculate_outlined,
    iconBg: const Color(0xFFE3F2FD),
    iconColor: const Color(0xFF1E88E5),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Aljabar', items: [
        MateriItem(nomor: '01', judul: 'Persamaan Linear', tanggal: '15-01-2026',
            konten: 'Persamaan linear adalah persamaan yang variabelnya memiliki pangkat tertinggi satu.'),
        MateriItem(nomor: '02', judul: 'Persamaan Kuadrat', type: MateriType.kuis,
            konten: 'Persamaan kuadrat adalah persamaan polinomial berderajat dua dengan bentuk umum ax² + bx + c = 0.'),
      ]),
      BagianMateri(judul: 'Bagian 02 - Geometri', items: [
        MateriItem(nomor: '03', judul: 'Luas dan Keliling Bangun Datar', tanggal: '22-01-2026', type: MateriType.tugas,
            konten: 'Bangun datar adalah bangun dua dimensi yang hanya memiliki panjang dan lebar.'),
      ]),
    ],
  ),
  MapelModel(
    id: 'bind',
    nama: 'Bahasa Indonesia',
    deskripsi: 'Bahasa dan Sastra Indonesia',
    jumlahMateri: 10,
    jumlahProyek: 3,
    icon: Icons.book_outlined,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFF5A623),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Teks', items: [
        MateriItem(nomor: '01', judul: 'Teks Deskripsi', tanggal: '10-01-2026',
            konten: 'Teks deskripsi adalah teks yang menggambarkan suatu objek secara rinci dan jelas.'),
        MateriItem(nomor: '02', judul: 'Teks Narasi', tanggal: '17-01-2026', type: MateriType.tugas,
            konten: 'Teks narasi adalah teks yang menceritakan suatu peristiwa atau kejadian secara kronologis.'),
      ]),
    ],
  ),
  MapelModel(
    id: 'bing',
    nama: 'Bahasa Inggris',
    deskripsi: 'English Language Skills',
    jumlahMateri: 15,
    jumlahProyek: 5,
    icon: Icons.language_outlined,
    iconBg: const Color(0xFFFCE4EC),
    iconColor: const Color(0xFFE91E63),
    bagian: [
      BagianMateri(judul: 'Chapter 01 - Greetings', items: [
        MateriItem(nomor: '01', judul: 'Introduction & Greetings',
            konten: 'Learning how to greet people in English formally and informally.'),
        MateriItem(nomor: '02', judul: 'Daily Conversation', type: MateriType.kuis,
            konten: 'Practice everyday English conversations for various situations.'),
      ]),
    ],
  ),
  MapelModel(
    id: 'ppkn',
    nama: 'Pendidikan Pancasila',
    deskripsi: 'Nilai dan Norma Bangsa',
    jumlahMateri: 6,
    jumlahProyek: 1,
    icon: Icons.account_balance_outlined,
    iconBg: const Color(0xFFEDE7F6),
    iconColor: const Color(0xFF7B1FA2),
    bagian: [
      BagianMateri(judul: 'Bagian 01 - Pancasila', items: [
        MateriItem(nomor: '01', judul: 'Sejarah Pancasila',
            konten: 'Pancasila sebagai dasar negara Indonesia ditetapkan pada 18 Agustus 1945.'),
        MateriItem(nomor: '02', judul: 'Nilai-nilai Pancasila', type: MateriType.tugas,
            konten: 'Lima sila Pancasila mengandung nilai-nilai luhur yang menjadi pedoman kehidupan berbangsa.'),
      ]),
    ],
  ),
];