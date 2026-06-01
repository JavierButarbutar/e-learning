
import 'package:flutter/material.dart';
import '../../data/models/soal_model.dart';

class SoalCard extends StatelessWidget {
  final SoalModel soal;
  const SoalCard({super.key, required this.soal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Badge(
              label: 'Soal ${soal.nomor}',
              bgColor: const Color(0xFF2E7D32),
              textColor: Colors.white,
            ),
            const SizedBox(width: 8),
            _Badge(
              label: soal.tipe == TipeSoal.pilihanGanda
                  ? 'Pilihan Ganda'
                  : 'Esai',
              bgColor: soal.tipe == TipeSoal.pilihanGanda
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFFF3E0),
              textColor: soal.tipe == TipeSoal.pilihanGanda
                  ? const Color(0xFF1E88E5)
                  : const Color(0xFFF5A623),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(soal.pertanyaan,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                    height: 1.7,
                  )),
              if (soal.gambarSoalUrl != null) ...[
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFEEEEEE)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    soal.gambarSoalUrl!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, p) {
                      if (p == null) return child;
                      return Container(
                        height: 160,
                        alignment: Alignment.center,
                        color: const Color(0xFFF5F5F5),
                        child: const CircularProgressIndicator(
                            color: Color(0xFF2E7D32), strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      color: const Color(0xFFF5F5F5),
                      child: const Text('Gambar tidak dapat dimuat',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBBBBBB),
                              fontFamily: 'Poppins')),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _Badge(
      {required this.label,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: textColor)),
    );
  }
}