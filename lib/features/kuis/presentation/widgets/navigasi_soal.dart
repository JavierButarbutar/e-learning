import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/kuis_provider.dart';

class NavigasiSoal extends StatelessWidget {
  const NavigasiSoal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KuisProvider>(
      builder: (context, kuis, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigasi Soal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(kuis.soalList.length, (i) {
                final isCurrent = i == kuis.currentSoal;
                final soal = kuis.soalList[i];
                final isAnswered = kuis.sudahDijawab(soal.idSoal);

                return GestureDetector(
                  onTap: () => kuis.goToSoal(i),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isCurrent
                          ? const Color(0xFF2E7D32)
                          : isAnswered
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF2E7D32)
                            : isAnswered
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: isCurrent
                              ? Colors.white
                              : isAnswered
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}