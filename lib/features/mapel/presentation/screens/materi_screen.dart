import 'package:flutter/material.dart';
import '../../data/models/mapel_model.dart';
import 'detail_materi_screen.dart';

class MateriScreen extends StatelessWidget {
  final MapelModel mapel;
  const MateriScreen({super.key, required this.mapel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // Header
        Container(
          color: const Color(0xFF1B5E20),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 0),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Materi Pembelajaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
            ]),
            const SizedBox(height: 10),
            // Hero banner mapel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mapel.nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Poppins', height: 1.3)),
                const SizedBox(height: 4),
                Text(mapel.deskripsi,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Poppins')),
              ]),
            ),
            const SizedBox(height: 12),
          ]),
        ),

        // Konten materi
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kuis banner (jika ada)
                _KuisBanner(),
                const SizedBox(height: 10),

                // Bagian-bagian materi
                ...mapel.bagian.map((b) => _BagianSection(bagian: b, namaMapel: mapel.nama,),),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Banner kuis ───────────────────────────────────────────────
class _KuisBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE65100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz_outlined, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kuis Evaluasi Bab 1',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: Color(0xFFE65100), fontFamily: 'Poppins')),
            SizedBox(height: 2),
            Text('15 mnt · 15 Soal',
              style: TextStyle(fontSize: 10, color: Color(0xFFF57C00),
                  fontFamily: 'Poppins')),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE65100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Mulai Kuis',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}

// ── Section bagian materi ─────────────────────────────────────
class _BagianSection extends StatelessWidget {
  final BagianMateri bagian;
  final String namaMapel;

  const _BagianSection({
    super.key,
    required this.bagian,
    required this.namaMapel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                bagian.judul,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),

        ...bagian.items.map(
          (item) => _MateriTile(
            item: item,
            namaMapel: namaMapel,
          ),
        ),
      ],
    );
  }
}

// ── Tile satu item materi ─────────────────────────────────────
class _MateriTile extends StatelessWidget {
  final MateriItem item;
  final String namaMapel;

  const _MateriTile({
    required this.item,
    required this.namaMapel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailMateriScreen(item: item, namaMapel: namaMapel,))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          // Nomor
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            child: Center(
              child: Text(item.nomor,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.judul,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              if (item.tanggal != null) ...[
                const SizedBox(height: 2),
                Text(item.tanggal!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                      fontFamily: 'Poppins')),
              ],
            ]),
          ),
          // Badge type
          if (item.type == MateriType.tugas)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7043),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Tugas',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
            )
          else if (item.type == MateriType.kuis)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Kuis',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
            )
          else
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
        ]),
      ),
    );
  }
}