
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/kuis_provider.dart';

class KuisHeader extends StatelessWidget {
  final VoidCallback onBack;
  const KuisHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<KuisProvider>(
      builder: (context, kuis, _) {
        final total = kuis.soalList.length;
        final current = kuis.currentSoal + 1;

        return Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kuis.kuis?.judulKuis ?? '',
                            style: const TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Poppins')),
                        Text(kuis.kuis?.namaMapel ?? '',
                            style: TextStyle(fontSize: 11,
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 15, color: kuis.timerColor),
                        const SizedBox(width: 4),
                        Text(kuis.timerLabel,
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: kuis.timerColor,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Soal $current/$total',
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Poppins')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? current / total : 0,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF5A623)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}