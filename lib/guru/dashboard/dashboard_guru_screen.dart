// lib/guru/dashboard/dashboard_guru_screen.dart

import 'package:flutter/material.dart';
import '../core/jadwal_model.dart';

class DashboardGuruScreen extends StatefulWidget {
  const DashboardGuruScreen({super.key});

  @override
  State<DashboardGuruScreen> createState() => _DashboardGuruScreenState();
}

class _DashboardGuruScreenState extends State<DashboardGuruScreen> {
  late String _selectedHari;
  late List<String> _weekDays;   // ['Senin','Selasa',...] mulai hari ini
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedHari = namaHari(_today);

    // Buat 5 hari tampil dari hari ini (Mon-Fri)
    _weekDays = _buildWeekDays();
  }

  List<String> _buildWeekDays() {
    // Tampilkan Senin-Jumat minggu ini
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
    return List.generate(5, (i) {
      final d = monday.add(Duration(days: i));
      return namaHari(d);
    });
  }

  List<JadwalItem> get _jadwalHariIni =>
      dummyJadwalGuru[_selectedHari] ?? [];

  JadwalItem? get _jadwalAktif {
    final now = DateTime.now();
    for (final j in _jadwalHariIni) {
      if (j.sedangBerlangsung) return j;
    }
    return null;
  }

  JadwalItem? get _jadwalBerikutnya {
    final now = DateTime.now();
    for (final j in _jadwalHariIni) {
      if (j.jamMulaiHariIni.isAfter(now)) return j;
    }
    return null;
  }

  String _tanggalHariIni() {
    const hari = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${hari[_today.weekday - 1]}, '
        '${_today.day} ${bulan[_today.month - 1]} ${_today.year}';
  }

  @override
  Widget build(BuildContext context) {
    final jadwal = _jadwalHariIni;
    final aktif  = _jadwalAktif;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        _buildHeader(context, aktif),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              // ── Day picker ──
              _DayPicker(
                weekDays: _weekDays,
                today: _today,
                selected: _selectedHari,
                onSelect: (h) => setState(() => _selectedHari = h),
              ),

              const SizedBox(height: 20),

              // ── Label ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('MATA PELAJARAN BERIKUTNYA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        color: Color(0xFF888888), letterSpacing: 0.8,
                        fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 12),

              // ── List jadwal ──
              if (jadwal.isEmpty)
                _EmptyJadwal()
              else
                ...jadwal.map((j) => _JadwalCard(item: j)),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, JadwalItem? aktif) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 0),
      child: Column(children: [
        // Row: sekolah + notif
        Row(children: [
          const Text('SMKN 1 TAMANAN',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                color: Colors.white, fontFamily: 'Poppins',
                letterSpacing: 0.5)),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 20),
          ),
        ]),
        const SizedBox(height: 14),

        // Jadwal mengajar title
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Jadwal Mengajar',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: Colors.white, fontFamily: 'Poppins')),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(_tanggalHariIni(),
            style: TextStyle(fontSize: 13,
                color: Colors.white.withOpacity(0.72),
                fontFamily: 'Poppins')),
        ),
        const SizedBox(height: 16),

        // Banner kelas aktif (jika sedang mengajar)
        if (aktif != null) ...[
          _ActiveClassBanner(item: aktif),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 10),
      ]),
    );
  }
}

// ── Banner kelas yang sedang berlangsung ──────────────────────
class _ActiveClassBanner extends StatelessWidget {
  final JadwalItem item;
  const _ActiveClassBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5A623),
          ),
          child: const Icon(Icons.volume_up_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Saatnya mengajar di',
              style: TextStyle(fontSize: 11, color: Colors.white70,
                  fontFamily: 'Poppins')),
            Text('${item.namaKelas} ${item.mataPelajaran}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
            Row(children: [
              Text('${item.ruangan} · ',
                style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Poppins')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Sedang Berlangsung',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
              ),
            ]),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Absensi',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}

// ── Day picker horizontal ─────────────────────────────────────
class _DayPicker extends StatelessWidget {
  final List<String> weekDays;
  final DateTime today;
  final String selected;
  final ValueChanged<String> onSelect;

  const _DayPicker({
    required this.weekDays, required this.today,
    required this.selected, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final monday = today.subtract(Duration(days: today.weekday - 1));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: List.generate(weekDays.length, (i) {
          final hari    = weekDays[i];
          final date    = monday.add(Duration(days: i));
          final isToday = hari == namaHari(today);
          final isSel   = hari == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(hari),
              child: Column(children: [
                Text(singkatanHari(hari),
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: isSel
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF888888),
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 6),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSel
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    border: isToday && !isSel
                        ? Border.all(
                            color: const Color(0xFF2E7D32), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text('${date.day}',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: isSel
                            ? Colors.white
                            : isToday
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1A1A1A),
                        fontFamily: 'Poppins',
                      )),
                  ),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ── Card satu sesi jadwal ─────────────────────────────────────
class _JadwalCard extends StatelessWidget {
  final JadwalItem item;
  const _JadwalCard({required this.item});

  bool get _isRapat => item.mataPelajaran == 'Rapat Guru';

  Color get _iconBg => _isRapat
      ? const Color(0xFFFFF3E0)
      : const Color(0xFFE8F5E9);

  Color get _iconColor => _isRapat
      ? const Color(0xFFF5A623)
      : const Color(0xFF2E7D32);

  IconData get _icon => _isRapat
      ? Icons.groups_outlined
      : Icons.science_outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Jam
        SizedBox(
          width: 48,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.jamMulai,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(item.jamSelesai,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
          ]),
        ),

        // Garis vertikal
        Container(
          width: 2, height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Icon
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_icon, color: _iconColor, size: 20),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.namaKelas,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(item.mataPelajaran,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.room_outlined, size: 13,
                  color: Color(0xFF888888)),
              const SizedBox(width: 3),
              Text('${item.ruangan}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
              const Text(' • ', style: TextStyle(color: Color(0xFF888888))),
              Text(item.gedung,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyJadwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.event_available_outlined,
              color: Color(0xFF2E7D32), size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Tidak ada jadwal hari ini',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        const Text('Nikmati hari libur mengajarmu!',
          style: TextStyle(fontSize: 13, color: Color(0xFF888888),
              fontFamily: 'Poppins')),
      ]),
    );
  }
}