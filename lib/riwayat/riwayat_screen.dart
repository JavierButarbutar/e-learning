import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  static final _data = {
    'Januari 2024': [
      _RiwayatItem('Senin, 15 Jan 2024',  '07:15 WIB', 'Matematika',       'Persamaan Linear',        'hadir'),
      _RiwayatItem('Selasa, 16 Jan 2024', '07:00 WIB', 'Bahasa Indonesia',  'Teks Deskripsi',         'sakit'),
      _RiwayatItem('Rabu, 17 Jan 2024',   '07:20 WIB', 'IPAS',              'Apa itu IPAS?',          'hadir'),
      _RiwayatItem('Kamis, 18 Jan 2024',  '07:05 WIB', 'Bahasa Inggris',    'Introduction',           'hadir'),
      _RiwayatItem('Jumat, 19 Jan 2024',  '07:30 WIB', 'PPKn',              'Sejarah Pancasila',      'izin'),
      _RiwayatItem('Senin, 22 Jan 2024',  '07:10 WIB', 'Matematika',        'Persamaan Kuadrat',      'hadir'),
      _RiwayatItem('Selasa, 23 Jan 2024', '07:00 WIB', 'IPAS',              'Sel dan Jaringan',       'hadir'),
      _RiwayatItem('Rabu, 24 Jan 2024',   '07:15 WIB', 'Bahasa Indonesia',  'Teks Narasi',            'hadir'),
      _RiwayatItem('Kamis, 25 Jan 2024',  '-',         'Bahasa Inggris',    'Daily Conversation',     'alfa'),
    ],
    'Februari 2024': [
      _RiwayatItem('Senin, 5 Feb 2024',   '07:08 WIB', 'Matematika',        'Bangun Datar',           'hadir'),
      _RiwayatItem('Selasa, 6 Feb 2024',  '07:00 WIB', 'IPAS',              'Organ Reproduksi',       'hadir'),
      _RiwayatItem('Rabu, 7 Feb 2024',    '07:22 WIB', 'Bahasa Indonesia',  'Teks Eksposisi',         'hadir'),
      _RiwayatItem('Kamis, 8 Feb 2024',   '-',         'Bahasa Inggris',    'Vocabulary',             'sakit'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Header hijau ──
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF2E7D32),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Presensi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                        color: Colors.white, fontFamily: 'Poppins')),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.filter_list_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // ── Statistik akademik ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatistikCard(),
            ),
          ),

          // ── Riwayat per bulan ──
          ..._data.entries.map((entry) => _buildBulan(entry.key, entry.value)),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildBulan(String bulan, List<_RiwayatItem> items) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bulan,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            ...items.map((item) => _RiwayatCard(item: item)),
          ],
        ),
      ),
    );
  }
}

// ── Card statistik ────────────────────────────────────────────
class _StatistikCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATISTIK AKADEMIK',
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6),
                letterSpacing: 1, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('95%',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins',
                    height: 1.0)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('Kehadiran',
                  style: TextStyle(fontSize: 14, color: Color(0xFFF5A623),
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: const [
            _StatChip(label: '180', sub: 'Hadir'),
            SizedBox(width: 10),
            _StatChip(label: '5', sub: 'Izin'),
            SizedBox(width: 10),
            _StatChip(label: '2', sub: 'Alfa'),
          ]),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _ExtraInfo(
              icon: Icons.calendar_today_outlined,
              label: 'Paling Awal',
              value: '06:45 WIB 12 Jan',
            )),
            const SizedBox(width: 12),
            Expanded(child: _ExtraInfo(
              icon: Icons.timer_outlined,
              label: 'Total Jam',
              value: '1.240 Jam Belajar',
            )),
          ]),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, sub;
  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.w800, color: Colors.white,
            fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10,
            color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _ExtraInfo extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ExtraInfo({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10,
                color: Colors.white.withOpacity(0.6), fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: Colors.white,
                fontFamily: 'Poppins')),
          ]),
        ),
      ]),
    );
  }
}

// ── Card satu item riwayat ────────────────────────────────────
class _RiwayatCard extends StatelessWidget {
  final _RiwayatItem item;
  const _RiwayatCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'hadir': return const Color(0xFF2E7D32);
      case 'sakit': return const Color(0xFF1E88E5);
      case 'izin':  return const Color(0xFFF5A623);
      default:      return const Color(0xFFE53935);
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'hadir': return const Color(0xFFE8F5E9);
      case 'sakit': return const Color(0xFFE3F2FD);
      case 'izin':  return const Color(0xFFFFF3E0);
      default:      return const Color(0xFFFFEBEE);
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case 'hadir': return Icons.check_circle_outline_rounded;
      case 'sakit': return Icons.local_hospital_outlined;
      case 'izin':  return Icons.info_outline_rounded;
      default:      return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        // Icon status
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_statusIcon, color: _statusColor, size: 22),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.hari,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.menu_book_outlined,
                  size: 12, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.mapel,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                      fontFamily: 'Poppins'),
                  overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.book_outlined, size: 12, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.materi,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                      fontFamily: 'Poppins'),
                  overflow: TextOverflow.ellipsis),
              ),
            ]),
            if (item.jam != '-') ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.access_time_rounded,
                    size: 12, color: Color(0xFF888888)),
                const SizedBox(width: 4),
                Text('Masuk: ${item.jam}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                      fontFamily: 'Poppins')),
              ]),
            ],
          ]),
        ),

        // Badge status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(item.status.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: _statusColor, fontFamily: 'Poppins',
                letterSpacing: 0.3)),
        ),
      ]),
    );
  }
}

class _RiwayatItem {
  final String hari, jam, mapel, materi, status;
  const _RiwayatItem(this.hari, this.jam, this.mapel, this.materi, this.status);
}