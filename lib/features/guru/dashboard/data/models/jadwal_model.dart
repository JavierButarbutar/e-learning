// lib/guru/core/jadwal_model.dart
// Model data jadwal mengajar guru (dummy — sambungkan ke API)

class JadwalItem {
  final String jamMulai;       // "10:00"
  final String jamSelesai;     // "11:30"
  final String namaKelas;      // "Kelas 12 TITL"
  final String mataPelajaran;  // "Biologi"
  final String ruangan;        // "Lab Biologi"
  final String gedung;         // "Gedung 5"
  final String hari;           // "Senin"

  const JadwalItem({
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaKelas,
    required this.mataPelajaran,
    required this.ruangan,
    required this.gedung,
    required this.hari,
  });

  /// Kembalikan DateTime jam mulai hari ini (untuk notifikasi)
  DateTime get jamMulaiHariIni {
    final now = DateTime.now();
    final parts = jamMulai.split(':');
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }

  /// true jika kelas sedang berlangsung sekarang
  bool get sedangBerlangsung {
    final now = DateTime.now();
    final mulai   = jamMulaiHariIni;
    final selesai = jamMulaiHariIni.add(
        Duration(minutes: _durasiMenit));
    return now.isAfter(mulai) && now.isBefore(selesai);
  }

  int get _durasiMenit {
    final parts = jamSelesai.split(':');
    final endParts = jamMulai.split(':');
    return (int.parse(parts[0]) * 60 + int.parse(parts[1])) -
        (int.parse(endParts[0]) * 60 + int.parse(endParts[1]));
  }
}

// ── Dummy jadwal per hari ──────────────────────────────────────
final Map<String, List<JadwalItem>> dummyJadwalGuru = {
  'Senin': [
    JadwalItem(jamMulai: '07:00', jamSelesai: '08:30',
        namaKelas: 'Kelas 10 TKJ 1', mataPelajaran: 'Sains',
        ruangan: 'Lab IPA', gedung: 'Gedung A', hari: 'Senin'),
    JadwalItem(jamMulai: '10:00', jamSelesai: '11:30',
        namaKelas: 'Kelas 12 TITL', mataPelajaran: 'Biologi',
        ruangan: 'Lab Biologi', gedung: 'Gedung 5', hari: 'Senin'),
    JadwalItem(jamMulai: '13:00', jamSelesai: '14:30',
        namaKelas: 'Kelas 11 PBS 2', mataPelajaran: 'Kimia',
        ruangan: 'Ruang 12', gedung: 'Gedung Utama', hari: 'Senin'),
    JadwalItem(jamMulai: '15:00', jamSelesai: '16:00',
        namaKelas: 'Rapat', mataPelajaran: 'Rapat Guru',
        ruangan: 'Aula Guru', gedung: 'Gedung Utama', hari: 'Senin'),
  ],
  'Selasa': [
    JadwalItem(jamMulai: '08:00', jamSelesai: '09:30',
        namaKelas: 'Kelas 11 TKJ 1', mataPelajaran: 'Biologi',
        ruangan: 'Lab Biologi', gedung: 'Gedung 5', hari: 'Selasa'),
    JadwalItem(jamMulai: '11:00', jamSelesai: '12:30',
        namaKelas: 'Kelas 10 RPL 1', mataPelajaran: 'Sains',
        ruangan: 'Ruang 8', gedung: 'Gedung B', hari: 'Selasa'),
  ],
  'Rabu': [
    JadwalItem(jamMulai: '07:00', jamSelesai: '08:30',
        namaKelas: 'Kelas 12 PBS 1', mataPelajaran: 'Kimia',
        ruangan: 'Lab Kimia', gedung: 'Gedung 3', hari: 'Rabu'),
    JadwalItem(jamMulai: '10:00', jamSelesai: '11:30',
        namaKelas: 'Kelas 11 TITL', mataPelajaran: 'Biologi',
        ruangan: 'Lab Biologi', gedung: 'Gedung 5', hari: 'Rabu'),
    JadwalItem(jamMulai: '13:00', jamSelesai: '14:30',
        namaKelas: 'Kelas 10 TKJ 2', mataPelajaran: 'Sains',
        ruangan: 'Ruang 5', gedung: 'Gedung A', hari: 'Rabu'),
  ],
  'Kamis': [
    JadwalItem(jamMulai: '09:00', jamSelesai: '10:30',
        namaKelas: 'Kelas 12 TKJ 1', mataPelajaran: 'Biologi',
        ruangan: 'Lab Biologi', gedung: 'Gedung 5', hari: 'Kamis'),
    JadwalItem(jamMulai: '13:00', jamSelesai: '14:30',
        namaKelas: 'Kelas 11 RPL 2', mataPelajaran: 'Kimia',
        ruangan: 'Lab Kimia', gedung: 'Gedung 3', hari: 'Kamis'),
  ],
  'Jumat': [
    JadwalItem(jamMulai: '07:00', jamSelesai: '08:00',
        namaKelas: 'Kelas 10 PBS 1', mataPelajaran: 'Sains',
        ruangan: 'Ruang 3', gedung: 'Gedung B', hari: 'Jumat'),
    JadwalItem(jamMulai: '09:00', jamSelesai: '10:30',
        namaKelas: 'Kelas 12 RPL 1', mataPelajaran: 'Biologi',
        ruangan: 'Lab Biologi', gedung: 'Gedung 5', hari: 'Jumat'),
  ],
};

const _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

/// Ambil nama hari dari DateTime
String namaHari(DateTime dt) {
  const map = {1: 'Senin', 2: 'Selasa', 3: 'Rabu',
      4: 'Kamis', 5: 'Jumat', 6: 'Sabtu', 7: 'Minggu'};
  return map[dt.weekday] ?? 'Senin';
}

/// Singkatan 3 huruf hari
String singkatanHari(String hari) {
  return hari.substring(0, 3).toUpperCase();
}

const hariList = _hariList;