import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/soal_model.dart';
import '../../provider/kuis_provider.dart';




class PilihanGandaWidget extends StatelessWidget {
  final SoalModel soal;

  const PilihanGandaWidget({super.key, required this.soal});

  @override
  Widget build(BuildContext context) {
    return Consumer<KuisProvider>(
      builder: (context, kuis, _) {
        final pilihan = soal.pilihan ?? [];
        final adaGambar = pilihan.any((p) => p.gambarUrl != null);

        if (adaGambar) {
          return _PilihanGrid(soal: soal, pilihan: pilihan, kuis: kuis);
        }
        return _PilihanList(soal: soal, pilihan: pilihan, kuis: kuis);
      },
    );
  }
}


class _PilihanList extends StatelessWidget {
  final SoalModel soal;
  final List<PilihanModel> pilihan;
  final KuisProvider kuis;

  const _PilihanList({
    required this.soal,
    required this.pilihan,
    required this.kuis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: pilihan.map((p) {

        final isSelected = kuis.jawaban[soal.idSoal] == p.idPilihan;

        return GestureDetector(
          onTap: () => kuis.pilihJawaban(soal.idSoal, p.idPilihan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFEEEEEE),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _LabelBullet(label: p.label, isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p.teks ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}


class _PilihanGrid extends StatelessWidget {
  final SoalModel soal;
  final List<PilihanModel> pilihan;
  final KuisProvider kuis;

  const _PilihanGrid({
    required this.soal,
    required this.pilihan,
    required this.kuis,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: pilihan.map((p) {
        final isSelected = kuis.jawaban[soal.idSoal] == p.idPilihan;

        return GestureDetector(
          onTap: () => kuis.pilihJawaban(soal.idSoal, p.idPilihan),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFEEEEEE),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Expanded(
                  child: p.gambarUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            p.gambarUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2E7D32),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                _imgError(),
                          ),
                        )
                      : _imgError(),
                ),


                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      _LabelBullet(
                          label: p.label, isSelected: isSelected),
                      if (p.teks != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            p.teks!,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: const Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32), size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _imgError() => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const Icon(Icons.broken_image_outlined,
            color: Color(0xFFBBBBBB), size: 28),
      );
}


class _LabelBullet extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _LabelBullet({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? const Color(0xFF2E7D32)
            : const Color(0xFFF5F5F5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            color: isSelected ? Colors.white : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}