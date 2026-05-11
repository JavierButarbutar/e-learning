import 'package:flutter/material.dart';

// ── Model notifikasi guru ─────────────────────────────────────
enum NotifGuruType { jadwal, tugasMasuk, absensi, pengumuman }

class NotifGuruItem {
  final String id;
  final NotifGuruType type;
  final String judul;
  final String isi;
  final String waktu;
  final bool dibaca;
  final String? namaKelas;
  final String? mataPelajaran;

  const NotifGuruItem({
    required this.id,
    required this.type,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
    this.namaKelas,
    this.mataPelajaran,
  });

  NotifGuruItem copyWith({bool? dibaca}) => NotifGuruItem(
    id: id, type: type, judul: judul, isi: isi,
    waktu: waktu, dibaca: dibaca ?? this.dibaca,
    namaKelas: namaKelas, mataPelajaran: mataPelajaran,
  );
}

// ── Dummy data ────────────────────────────────────────────────
final _dummyNotifGuru = [
  NotifGuruItem(
    id: '1', type: NotifGuruType.jadwal, dibaca: false,
    judul: 'Pengingat Jadwal Mengajar',
    isi: '10 menit lagi kamu mengajar Biologi di Kelas 12 TITL — Lab Biologi, Gedung 5.',
    waktu: '09:50', namaKelas: 'Kelas 12 TITL', mataPelajaran: 'Biologi',
  ),
  NotifGuruItem(
    id: '2', type: NotifGuruType.tugasMasuk, dibaca: false,
    judul: 'Tugas Baru Masuk',
    isi: 'Muhammad Ibnu telah mengumpulkan tugas "Makalah Organ Reproduksi" untuk Kelas 12 TITL.',
    waktu: '09:32', namaKelas: 'Kelas 12 TITL', mataPelajaran: 'Biologi',
  ),
  NotifGuruItem(
    id: '3', type: NotifGuruType.tugasMasuk, dibaca: false,
    judul: 'Tugas Baru Masuk',
    isi: 'Siti Rahayu telah mengumpulkan tugas "Makalah Organ Reproduksi" untuk Kelas 12 TITL.',
    waktu: '09:15', namaKelas: 'Kelas 12 TITL', mataPelajaran: 'Biologi',
  ),
  NotifGuruItem(
    id: '4', type: NotifGuruType.absensi, dibaca: false,
    judul: 'Absensi Belum Dibuka',
    isi: 'Kamu belum membuka absensi untuk Kelas 10 TKJ 1 — Sains. Jadwal dimulai 07:00.',
    waktu: '07:05', namaKelas: 'Kelas 10 TKJ 1', mataPelajaran: 'Sains',
  ),
  NotifGuruItem(
    id: '5', type: NotifGuruType.pengumuman, dibaca: true,
    judul: 'Pengumuman Sekolah',
    isi: 'Rapat guru rutin akan dilaksanakan Senin, 27 April 2026 pukul 15:00 di Aula Utama.',
    waktu: 'Kemarin',
  ),
  NotifGuruItem(
    id: '6', type: NotifGuruType.jadwal, dibaca: true,
    judul: 'Pengingat Jadwal Mengajar',
    isi: '10 menit lagi kamu mengajar Kimia di Kelas 11 PBS 2 — Ruang 12, Gedung Utama.',
    waktu: 'Kemarin', namaKelas: 'Kelas 11 PBS 2', mataPelajaran: 'Kimia',
  ),
  NotifGuruItem(
    id: '7', type: NotifGuruType.tugasMasuk, dibaca: true,
    judul: '3 Tugas Baru Masuk',
    isi: '3 siswa Kelas 11 PBS 2 telah mengumpulkan tugas "Laporan Kimia Bab 3".',
    waktu: '2 hari lalu', namaKelas: 'Kelas 11 PBS 2', mataPelajaran: 'Kimia',
  ),
];

// ─────────────────────────────────────────────────────────────
// NOTIFIKASI GURU SCREEN
// ─────────────────────────────────────────────────────────────
class NotifikasiGuruScreen extends StatefulWidget {
  const NotifikasiGuruScreen({super.key});

  @override
  State<NotifikasiGuruScreen> createState() => _NotifikasiGuruScreenState();
}

class _NotifikasiGuruScreenState extends State<NotifikasiGuruScreen> {
  late List<NotifGuruItem> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = List.from(_dummyNotifGuru);
  }

  int get _unreadCount => _notifs.where((n) => !n.dibaca).length;

  void _tandaiSemua() => setState(() {
    _notifs = _notifs.map((n) => n.copyWith(dibaca: true)).toList();
  });

  void _tandaiSatu(String id) => setState(() {
    _notifs = _notifs.map((n) => n.id == id ? n.copyWith(dibaca: true) : n).toList();
  });

  void _hapusSatu(String id) => setState(() {
    _notifs.removeWhere((n) => n.id == id);
  });

  @override
  Widget build(BuildContext context) {
    final belumDibaca = _notifs.where((n) => !n.dibaca).toList();
    final sudahDibaca = _notifs.where((n) => n.dibaca).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        _buildHeader(context),
        Expanded(
          child: _notifs.isEmpty
              ? _EmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // ── Belum dibaca ──
                    if (belumDibaca.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'Belum Dibaca',
                        count: belumDibaca.length,
                      ),
                      const SizedBox(height: 8),
                      ...belumDibaca.map((n) => _NotifCard(
                        item: n,
                        onTap: () => _tandaiSatu(n.id),
                        onDismiss: () => _hapusSatu(n.id),
                      )),
                      const SizedBox(height: 16),
                    ],

                    // ── Sudah dibaca ──
                    if (sudahDibaca.isNotEmpty) ...[
                      _SectionLabel(label: 'Sebelumnya'),
                      const SizedBox(height: 8),
                      ...sudahDibaca.map((n) => _NotifCard(
                        item: n,
                        onTap: () {},
                        onDismiss: () => _hapusSatu(n.id),
                      )),
                    ],
                  ],
                ),
        ),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 16),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            const Text('Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$_unreadCount',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Poppins')),
              ),
            ],
          ]),
        ),
        if (_unreadCount > 0)
          TextButton(
            onPressed: _tandaiSemua,
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text('Tandai semua',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85), fontFamily: 'Poppins')),
          ),
      ]),
    );
  }
}

// ── Section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int? count;
  const _SectionLabel({required this.label, this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
          color: Color(0xFF888888), letterSpacing: 0.5,
          fontFamily: 'Poppins')),
    if (count != null) ...[
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('$count',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins')),
      ),
    ],
  ]);
}

// ── Kartu notifikasi (swipe to dismiss) ──────────────────────
class _NotifCard extends StatelessWidget {
  final NotifGuruItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  Color get _iconBg {
    switch (item.type) {
      case NotifGuruType.jadwal:      return const Color(0xFFE8F5E9);
      case NotifGuruType.tugasMasuk:  return const Color(0xFFFFF3E0);
      case NotifGuruType.absensi:     return const Color(0xFFE3F2FD);
      case NotifGuruType.pengumuman:  return const Color(0xFFEDE7F6);
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case NotifGuruType.jadwal:      return const Color(0xFF2E7D32);
      case NotifGuruType.tugasMasuk:  return const Color(0xFFF5A623);
      case NotifGuruType.absensi:     return const Color(0xFF1E88E5);
      case NotifGuruType.pengumuman:  return const Color(0xFF7B1FA2);
    }
  }

  IconData get _icon {
    switch (item.type) {
      case NotifGuruType.jadwal:      return Icons.schedule_rounded;
      case NotifGuruType.tugasMasuk:  return Icons.assignment_turned_in_outlined;
      case NotifGuruType.absensi:     return Icons.qr_code_scanner_rounded;
      case NotifGuruType.pengumuman:  return Icons.campaign_outlined;
    }
  }

  String get _typeLabel {
    switch (item.type) {
      case NotifGuruType.jadwal:      return 'Jadwal';
      case NotifGuruType.tugasMasuk:  return 'Tugas Masuk';
      case NotifGuruType.absensi:     return 'Absensi';
      case NotifGuruType.pengumuman:  return 'Pengumuman';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.dibaca ? Colors.white : const Color(0xFFF0FAF0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.dibaca
                  ? const Color(0xFFEEEEEE)
                  : const Color(0xFFC8E6C9),
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge type + waktu
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_typeLabel,
                        style: TextStyle(fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _iconColor, fontFamily: 'Poppins')),
                    ),
                    const Spacer(),
                    Text(item.waktu,
                      style: const TextStyle(fontSize: 10,
                          color: Color(0xFFBBBBBB), fontFamily: 'Poppins')),
                  ]),
                  const SizedBox(height: 6),

                  // Judul
                  Text(item.judul,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.dibaca
                          ? FontWeight.w600 : FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 4),

                  // Isi
                  Text(item.isi,
                    style: const TextStyle(fontSize: 12,
                        color: Color(0xFF666666), fontFamily: 'Poppins',
                        height: 1.5)),

                  // Info kelas (jika ada)
                  if (item.namaKelas != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      _InfoChip(
                        icon: Icons.class_outlined,
                        label: item.namaKelas!,
                        color: _iconColor,
                        bg: _iconBg,
                      ),
                      const SizedBox(width: 6),
                      if (item.mataPelajaran != null)
                        _InfoChip(
                          icon: Icons.science_outlined,
                          label: item.mataPelajaran!,
                          color: _iconColor,
                          bg: _iconBg,
                        ),
                    ]),
                  ],

                  // Action button
                  if (!item.dibaca) ...[
                    const SizedBox(height: 10),
                    _ActionButton(type: item.type),
                  ],
                ],
              ),
            ),

            // Dot belum dibaca
            if (!item.dibaca)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 6, top: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2E7D32),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Chip info kelas/mapel ─────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;

  const _InfoChip({required this.icon, required this.label,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: color, fontFamily: 'Poppins')),
    ]),
  );
}

// ── Tombol aksi per tipe notifikasi ──────────────────────────
class _ActionButton extends StatelessWidget {
  final NotifGuruType type;
  const _ActionButton({required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (type) {
      case NotifGuruType.jadwal:
        label = 'Lihat Jadwal';
        color = const Color(0xFF2E7D32);
        break;
      case NotifGuruType.tugasMasuk:
        label = 'Periksa Tugas';
        color = const Color(0xFFF5A623);
        break;
      case NotifGuruType.absensi:
        label = 'Buka Absensi';
        color = const Color(0xFF1E88E5);
        break;
      case NotifGuruType.pengumuman:
        label = 'Lihat Detail';
        color = const Color(0xFF7B1FA2);
        break;
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white, fontFamily: 'Poppins')),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.notifications_none_rounded,
            color: Color(0xFF2E7D32), size: 42),
      ),
      const SizedBox(height: 16),
      const Text('Tidak ada notifikasi',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
      const SizedBox(height: 6),
      const Text('Semua notifikasi akan muncul di sini',
        style: TextStyle(fontSize: 13, color: Color(0xFF888888),
            fontFamily: 'Poppins')),
    ]),
  );
}