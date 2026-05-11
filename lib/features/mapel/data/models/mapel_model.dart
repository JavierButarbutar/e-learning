
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

  const MapelModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.jumlahMateri,
    required this.jumlahProyek,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  factory MapelModel.fromJson(Map<String, dynamic> json) {
    IconData icon = Icons.menu_book_outlined;
    Color bg = const Color(0xFFE8F5E9);
    Color color = const Color(0xFF2E7D32);

    final nama = (json['nama_mapel'] ?? '').toString().toLowerCase();

    if (nama.contains('matematika')) {
      icon = Icons.calculate_outlined;
      bg = const Color(0xFFE3F2FD);
      color = const Color(0xFF1E88E5);
    } else if (nama.contains('bahasa inggris')) {
      icon = Icons.language_outlined;
      bg = const Color(0xFFFCE4EC);
      color = const Color(0xFFE91E63);
    } else if (nama.contains('bahasa indonesia')) {
      icon = Icons.book_outlined;
      bg = const Color(0xFFFFF3E0);
      color = const Color(0xFFF5A623);
    } else if (nama.contains('pancasila')) {
      icon = Icons.account_balance_outlined;
      bg = const Color(0xFFEDE7F6);
      color = const Color(0xFF7B1FA2);
    }

    return MapelModel(
      id: json['id_mapel'].toString(),
      nama: json['nama_mapel'] ?? '-',
      deskripsi: json['kategori'] ?? '-',
      jumlahMateri: json['jumlah_materi'] ?? 0,
      jumlahProyek: json['jumlah_tugas'] ?? 0,
      icon: icon,
      iconBg: bg,
      iconColor: color,
    );
  }
}

enum MateriType { materi, tugas, kuis }

class MateriItem {
  final String id;
  final String nomor;
  final String judul;
  final String? tanggal;
  final MateriType type;
  final String? konten;
  final String? idTugas;

  // FILE API
  final String? fileUrl;
  final String? namaFile;
  final String? tipeFile;
  final String? ukuranFile;

  // Kuis
  final int? jumlahSoal;
  final int? durasiMenit;

  // Tugas
  final String? deadlineTugas;

  const MateriItem({
    required this.id,
    required this.nomor,
    required this.judul,
    this.tanggal,
    this.type = MateriType.materi,
    this.konten,
    this.fileUrl,
    this.namaFile,
    this.tipeFile,
    this.ukuranFile,
    this.jumlahSoal,
    this.durasiMenit,
    this.deadlineTugas,
    this.idTugas,
  });

  factory MateriItem.fromJson(Map<String, dynamic> json) {
  // Cek apakah materi ini punya tugas terlampir
  final tugasJson = json['tugas']; // ada di response GET /api/materi/{id}
  final hasTugas = tugasJson != null;

  return MateriItem(
    id: json['id_materi'].toString(),
    nomor: json['minggu_ke']?.toString() ?? '01',
    judul: json['judul_materi'] ?? '-',
    tanggal: json['tanggal_upload'],
    konten: json['deskripsi'],
    namaFile: json['file_name'],
    tipeFile: json['file_type'],
    ukuranFile: json['file_size']?.toString(),
    fileUrl: json['file_url'],
    idTugas: tugasJson?['id_tugas']?.toString(),

    // ✅ Deteksi type dari data yang ada
    type: hasTugas ? MateriType.tugas : MateriType.materi,

    // ✅ Ambil deadline dari nested tugas jika ada
    deadlineTugas: tugasJson?['tanggal_deadline'],
  );
}

  static MateriType _parseType(String? type) {
    switch (type) {
      case 'tugas':
        return MateriType.tugas;
      case 'kuis':
        return MateriType.kuis;
      default:
        return MateriType.materi;
    }
  }
}

class BagianMateri {
  final String judul;
  final List<MateriItem> items;

  const BagianMateri({
    required this.judul,
    required this.items,
  });
}