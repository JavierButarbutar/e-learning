import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/mapel_model.dart';
import '../../provider/mapel_provider.dart';
import 'detail_materi_screen.dart';

class MateriScreen extends StatefulWidget {
  final MapelModel mapel;

  const MateriScreen({
    super.key,
    required this.mapel,
  });

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MapelProvider>().getMateri(widget.mapel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapelProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Builder(builder: (_) {
              if (provider.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
              }
              if (provider.error != null) {
                return Center(child: Text(provider.error!,
                    style: const TextStyle(fontFamily: 'Poppins')));
              }
              if (provider.materi.isEmpty) {
                return const Center(
                  child: Text('Belum ada materi',
                      style: TextStyle(fontFamily: 'Poppins',
                          color: Color(0xFF888888))),
                );
              }

              // ── Kelompokkan berdasarkan minggu_ke / nomor ──
              final grouped = _groupByMinggu(provider.materi);

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: grouped.length,
                itemBuilder: (context, i) {
                  final section = grouped[i];
                  return _SectionGroup(
                    judul:    section.judul,
                    items:    section.items,
                    namaMapel: widget.mapel.nama,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Kelompokkan materi per minggu ───────────────────────
  List<_MateriSection> _groupByMinggu(List<MateriItem> list) {
    final Map<String, List<MateriItem>> map = {};

    for (final item in list) {
      final key = item.nomor.isNotEmpty ? item.nomor : '?';
      map.putIfAbsent(key, () => []).add(item);
    }

    // Urutkan berdasarkan nomor minggu
    final sorted = map.entries.toList()
      ..sort((a, b) {
        final na = int.tryParse(a.key) ?? 999;
        final nb = int.tryParse(b.key) ?? 999;
        return na.compareTo(nb);
      });

    return sorted.map((e) => _MateriSection(
      judul: 'Bagian ${e.key.padLeft(2, '0')}',
      items: e.value,
    )).toList();
  }

  // ── Header dengan gambar & info mapel ──────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF1B5E20),
      child: Column(
        children: [
          // AppBar row
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 10, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Materi Pembelajaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
            ]),
          ),

          // Banner mapel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              // Dekorasi lingkaran di background
              Positioned(
                right: -20, top: -20,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                right: 30, bottom: -30,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Konten
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.mapel.nama,
                        style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins', height: 1.2)),
                    const SizedBox(height: 4),
                    Text(widget.mapel.deskripsi,
                        style: TextStyle(fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data class untuk section
// ─────────────────────────────────────────────────────────────
class _MateriSection {
  final String judul;
  final List<MateriItem> items;
  const _MateriSection({required this.judul, required this.items});
}

// ─────────────────────────────────────────────────────────────
// Widget section (header + list tile)
// ─────────────────────────────────────────────────────────────
class _SectionGroup extends StatelessWidget {
  final String judul;
  final List<MateriItem> items;
  final String namaMapel;

  const _SectionGroup({
    required this.judul,
    required this.items,
    required this.namaMapel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header section ───────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(judul,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins')),
          ]),
        ),

        // ── Card group ───────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return _MateriTile(
                item: item,
                namaMapel: namaMapel,
                isLast: isLast,
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tile per materi
// ─────────────────────────────────────────────────────────────
class _MateriTile extends StatelessWidget {
  final MateriItem item;
  final String     namaMapel;
  final bool       isLast;

  const _MateriTile({
    required this.item,
    required this.namaMapel,
    required this.isLast,
  });

  // Warna berdasarkan tipe
  Color get _accentColor {
    switch (item.type) {
      case MateriType.tugas: return const Color(0xFFF5A623); // kuning
      case MateriType.kuis:  return const Color(0xFFFF7043); // orange
      default:               return const Color(0xFF2E7D32); // hijau
    }
  }

  Color get _bgColor {
    switch (item.type) {
      case MateriType.tugas: return const Color(0xFFFFF8E1);
      case MateriType.kuis:  return const Color(0xFFFBE9E7);
      default:               return const Color(0xFFE8F5E9);
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case MateriType.tugas: return Icons.assignment_outlined;
      case MateriType.kuis:  return Icons.quiz_outlined;
      default:               return Icons.menu_book_outlined;
    }
  }

  String? get _typeLabel {
    switch (item.type) {
      case MateriType.tugas: return 'Tugas';
      case MateriType.kuis:  return 'Kuis';
      default:               return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailMateriScreen(
          item: item,
          namaMapel: namaMapel,
        )),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Warna latar tile sesuai tipe (subtle)
          color: item.type != MateriType.materi
              ? _bgColor.withOpacity(0.4)
              : Colors.white,
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0))),
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16))
              : null,
        ),
        child: Row(children: [
          // ── Nomor / ikon ─────────────────────────────
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Icon(_typeIcon, size: 18, color: _accentColor),
            ),
          ),

          const SizedBox(width: 12),

          // ── Judul & tanggal ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.judul,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Poppins')),
                if (item.tanggal != null) ...[
                  const SizedBox(height: 2),
                  Text(item.tanggal!,
                      style: const TextStyle(fontSize: 11,
                          color: Color(0xFF888888),
                          fontFamily: 'Poppins')),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Badge tipe / chevron ─────────────────────
          if (_typeLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_typeLabel!,
                  style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins')),
            )
          else
            Icon(Icons.chevron_right_rounded,
                color: _accentColor.withOpacity(0.5), size: 22),
        ]),
      ),
    );
  }
}