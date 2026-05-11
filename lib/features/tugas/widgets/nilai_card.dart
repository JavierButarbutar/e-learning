import 'package:flutter/material.dart';

class NilaiCard extends StatelessWidget {
  final String nilai;
  final String? catatanGuru;

  const NilaiCard({
    super.key,
    required this.nilai,
    this.catatanGuru,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hasil Penilaian',
            style: TextStyle(fontSize: 11, color: Colors.white70,
                fontFamily: 'Poppins', letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(nilai,
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins', height: 1)),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('/ 100',
                style: TextStyle(fontSize: 16, color: Colors.white60,
                    fontFamily: 'Poppins')),
          ),
        ]),
        if (catatanGuru != null && catatanGuru!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan Guru',
                    style: TextStyle(fontSize: 10, color: Colors.white70,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text(catatanGuru!,
                    style: const TextStyle(fontSize: 13, color: Colors.white,
                        fontFamily: 'Poppins', height: 1.4)),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}