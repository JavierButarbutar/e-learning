import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});
  static final _data = [
    {'mapel': 'Matematika', 'tgl': 'Senin, 20 Jan 2026', 'status': 'Hadir'},
    {'mapel': 'IPAS', 'tgl': 'Senin, 20 Jan 2026', 'status': 'Hadir'},
    {'mapel': 'Bahasa Indonesia', 'tgl': 'Selasa, 21 Jan 2026', 'status': 'Hadir'},
    {'mapel': 'Matematika', 'tgl': 'Rabu, 22 Jan 2026', 'status': 'Izin'},
    {'mapel': 'Bahasa Inggris', 'tgl': 'Kamis, 23 Jan 2026', 'status': 'Hadir'},
    {'mapel': 'PPKn', 'tgl': 'Jumat, 24 Jan 2026', 'status': 'Alfa'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 20),
          width: double.infinity,
          child: const Text('Riwayat Presensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: _data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = _data[i];
              final isHadir = d['status'] == 'Hadir';
              final isIzin = d['status'] == 'Izin';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['mapel']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                    const SizedBox(height: 2),
                    Text(d['tgl']!, style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Poppins')),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHadir ? const Color(0xFFE8F5E9) : isIzin ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(d['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        color: isHadir ? const Color(0xFF2E7D32) : isIzin ? const Color(0xFFF5A623) : const Color(0xFFE53935))),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}