import 'package:flutter/material.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../mapel/mapel_screen.dart';
import '../mapel/materi_screen.dart';
import '../core/models/mapel_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _aktivitas = [
    {'mapel': 'Ilmu Pengetahuan Alam dan Sosial', 'materi': 'Organ Reproduksi Manusia'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Aktivitas terbaru ──
                  const Text('Aktivitas terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                  const SizedBox(height: 10),
                  ..._aktivitas.map((a) => _AktivitasCard(
                    mapel: a['mapel']!,
                    materi: a['materi']!,
                    onLanjut: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MateriScreen(mapel: dummyMapel[0]))),
                  )),

                  const SizedBox(height: 20),

                  // ── Mata Pelajaran ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mata Pelajaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MapelScreen(standalone: true))),
                        child: const Text('LIHAT SEMUA ›',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...dummyMapel.take(3).map((m) => _MapelCard(
                    mapel: m,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MateriScreen(mapel: m))),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Halo! Muhammad Ibnu',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: Colors.white, fontFamily: 'Poppins')),
                    SizedBox(height: 3),
                    Text('Selamat Datang di Aplikasi',
                      style: TextStyle(fontSize: 13, color: Color(0xB3FFFFFF),
                          fontFamily: 'Poppins')),
                  ],
                ),
              ),
              // Bell notifikasi
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
                child: Stack(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF5A623), width: 2.5),
                ),
                child: const Center(
                  child: Text('MI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: Color(0x99FFFFFF), size: 20),
              const SizedBox(width: 10),
              Text('Cari topik',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6),
                    fontFamily: 'Poppins')),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Card aktivitas terbaru ────────────────────────────────────
class _AktivitasCard extends StatelessWidget {
  final String mapel, materi;
  final VoidCallback onLanjut;

  const _AktivitasCard({required this.mapel, required this.materi, required this.onLanjut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mapel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(materi,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
          ]),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onLanjut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Lanjutkan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
          ),
        ),
      ]),
    );
  }
}

// ── Card mapel di dashboard ───────────────────────────────────
class _MapelCard extends StatelessWidget {
  final MapelModel mapel;
  final VoidCallback onTap;

  const _MapelCard({required this.mapel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: mapel.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(mapel.icon, color: mapel.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mapel.nama,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 3),
              Text('${mapel.jumlahMateri} Materi · ${mapel.jumlahProyek} Proyek',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 24),
        ]),
      ),
    );
  }
}