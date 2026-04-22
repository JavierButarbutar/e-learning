import 'package:flutter/material.dart';
import '../core/models/mapel_model.dart';
import 'materi_screen.dart';

class MapelScreen extends StatelessWidget {
  final bool standalone;
  const MapelScreen({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // Header hijau
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 12, 20, 0),
          child: Column(children: [
            Row(children: [
              if (standalone) ...[
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
              ],
              const Text('Daftar Mata Pelajaran',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
            ]),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KURIKULUM MERDEKA',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.8, fontFamily: 'Poppins')),
                const SizedBox(height: 6),
                const Text('Mulai Petualangan\nBelajar Kamu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Poppins', height: 1.3)),
                const SizedBox(height: 6),
                const Text('Muhammad Ibnu',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: Color(0xFFF5A623), fontFamily: 'Poppins')),
              ]),
            ),
            const SizedBox(height: 16),
          ]),
        ),

        // List mapel
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mata Pelajaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                ...dummyMapel.map((m) => _MapelTile(
                  mapel: m,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MateriScreen(mapel: m))),
                )),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _MapelTile extends StatelessWidget {
  final MapelModel mapel;
  final VoidCallback onTap;
  const _MapelTile({required this.mapel, required this.onTap});

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