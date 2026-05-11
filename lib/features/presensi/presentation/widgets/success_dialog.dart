import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isTerlambat;

  final String mapel;
  final String kelas;
  final String waktu;
  final double? jarak;

  final VoidCallback onBack;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isTerlambat,
    required this.mapel,
    required this.kelas,
    required this.waktu,
    required this.onBack,
    this.jarak,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isTerlambat
        ? const Color(0xFFF5A623)
        : const Color(0xFF2E7D32);

    final bgColor = isTerlambat
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────────────────────────────────────────
            // ICON
            // ───────────────────────────────────────────
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
              ),
              child: Icon(
                isTerlambat
                    ? Icons.access_time_rounded
                    : Icons.check_circle_rounded,
                color: primaryColor,
                size: 42,
              ),
            ),

            const SizedBox(height: 18),

            // ───────────────────────────────────────────
            // TITLE
            // ───────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 8),

            // ───────────────────────────────────────────
            // SUBTITLE
            // ───────────────────────────────────────────
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            // ───────────────────────────────────────────
            // DETAIL CARD
            // ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Mata Pelajaran',
                    value: mapel,
                  ),

                  const SizedBox(height: 12),

                  _DetailTile(
                    icon: Icons.class_outlined,
                    label: 'Kelas',
                    value: kelas,
                  ),

                  const SizedBox(height: 12),

                  _DetailTile(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu Masuk',
                    value: waktu,
                  ),

                  if (jarak != null) ...[
                    const SizedBox(height: 12),

                    _DetailTile(
                      icon: Icons.location_on_outlined,
                      label: 'Jarak',
                      value:
                          '${jarak!.toStringAsFixed(0)} meter',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ───────────────────────────────────────────
            // BUTTON
            // ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Kembali ke Dashboard',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DETAIL TILE
// ─────────────────────────────────────────────────────────────
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF888888),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}