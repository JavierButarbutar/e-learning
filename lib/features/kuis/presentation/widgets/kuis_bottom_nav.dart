import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/kuis_provider.dart';

class KuisBottomNav extends StatelessWidget {
  final VoidCallback onSelesai;
  const KuisBottomNav({super.key, required this.onSelesai});

  @override
  Widget build(BuildContext context) {
    return Consumer<KuisProvider>(
      builder: (context, kuis, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          color: Colors.white,
          child: Row(
            children: [
              if (kuis.currentSoal > 0) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: kuis.prev,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Sebelumnya',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: kuis.isLastSoal ? onSelesai : kuis.next,
                  icon: Icon(kuis.isLastSoal
                      ? Icons.check_circle_outline_rounded
                      : Icons.chevron_right_rounded),
                  label: Text(
                      kuis.isLastSoal
                          ? 'Selesaikan Kuis'
                          : 'Selanjutnya',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kuis.isLastSoal
                        ? const Color(0xFFF5A623)
                        : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}