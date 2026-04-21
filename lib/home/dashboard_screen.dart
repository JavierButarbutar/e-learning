import 'package:flutter/material.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../mapel/mapel_screen.dart';
import '../mapel/materi_screen.dart';
import '../core/models/mapel_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Dummy data aktivitas terbaru (materi yg belum selesai)
  static const _aktivitas = [
    {'mapel': 'Ilmu Pengetahuan Alam dan Sosial', 'materi': 'Organ Reproduksi Manusia'},
  ];

  static final _mapelList = dummyMapel.take(3).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header hijau ──
          _buildHeader(context),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aktivitas terbaru
                  const Text('Aktivitas terbaru',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  ..._aktivitas.map((a) => _AktivitasCard(
                    mapel: a['mapel']!,
                    materi: a['materi']!,
                    onLanjut: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MateriScreen(mapel: dummyMapel[0]))),
                  )),

                  const SizedBox(height: 16),

                  // Mata pelajaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mata Pelajaran',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke tab Mapel
                          DefaultTabController.of(context);
                          // Atau bisa gunakan callback ke MainScaffold
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MapelScreen(standalone: true)));
                        },
                        child: const Text('LIHAT SEMUA ›',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._mapelList.map((m) => _MapelCard(
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
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 14),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          color: Colors.white, fontFamily: 'Poppins')),
                    SizedBox(height: 2),
                    Text('Selamat Datang di Aplikasi',
                      style: TextStyle(fontSize: 12, color: Color(0xB3FFFFFF),
                          fontFamily: 'Poppins')),
                  ],
                ),
              ),
              // Notifikasi icon
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
                child: Stack(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 20),
                  ),
                  Positioned(
                    top: 4, right: 4,
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
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF5A623), width: 2),
                ),
                child: const Center(
                  child: Text('MI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: Color(0x99FFFFFF), size: 18),
              const SizedBox(width: 8),
              Text('Cari topik',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6),
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
  final String mapel;
  final String materi;
  final VoidCallback onLanjut;

  const _AktivitasCard({required this.mapel, required this.materi, required this.onLanjut});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mapel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(materi,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
          ]),
        ),
        GestureDetector(
          onTap: onLanjut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Lanjutkan',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: mapel.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(mapel.icon, color: mapel.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mapel.nama,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              Text('${mapel.jumlahMateri} Materi · ${mapel.jumlahProyek} Proyek',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
        ]),
      ),
    );
  }
}