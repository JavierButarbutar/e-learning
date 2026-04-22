import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  static final _data = [
    {'mapel': 'Matematika',       'tgl': 'Senin, 20 Jan 2026',   'status': 'Hadir'},
    {'mapel': 'IPAS',             'tgl': 'Senin, 20 Jan 2026',   'status': 'Hadir'},
    {'mapel': 'Bahasa Indonesia', 'tgl': 'Selasa, 21 Jan 2026',  'status': 'Hadir'},
    {'mapel': 'Matematika',       'tgl': 'Rabu, 22 Jan 2026',    'status': 'Izin'},
    {'mapel': 'Bahasa Inggris',   'tgl': 'Kamis, 23 Jan 2026',   'status': 'Hadir'},
    {'mapel': 'PPKn',             'tgl': 'Jumat, 24 Jan 2026',   'status': 'Alfa'},
    {'mapel': 'IPAS',             'tgl': 'Senin, 27 Jan 2026',   'status': 'Hadir'},
    {'mapel': 'Matematika',       'tgl': 'Selasa, 28 Jan 2026',  'status': 'Hadir'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 20),
          width: double.infinity,
          child: const Text('Riwayat Presensi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white, fontFamily: 'Poppins')),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: _data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final d = _data[i];
              final isHadir = d['status'] == 'Hadir';
              final isIzin  = d['status'] == 'Izin';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isHadir ? const Color(0xFFE8F5E9)
                           : isIzin  ? const Color(0xFFFFF3E0)
                                     : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHadir ? Icons.check_circle_outline_rounded
                               : isIzin ? Icons.info_outline_rounded
                                        : Icons.cancel_outlined,
                      size: 22,
                      color: isHadir ? const Color(0xFF2E7D32)
                           : isIzin  ? const Color(0xFFF5A623)
                                     : const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d['mapel']!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                      const SizedBox(height: 3),
                      Text(d['tgl']!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                            fontFamily: 'Poppins')),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isHadir ? const Color(0xFFE8F5E9)
                           : isIzin  ? const Color(0xFFFFF3E0)
                                     : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(d['status']!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: isHadir ? const Color(0xFF2E7D32)
                               : isIzin  ? const Color(0xFFF5A623)
                                         : const Color(0xFFE53935))),
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