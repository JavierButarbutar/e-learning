import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'dinilai':
        bg        = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label     = 'Sudah Dinilai';
        icon      = Icons.check_circle_rounded;
        break;
      case 'terlambat':
        bg        = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE53935);
        label     = 'Terlambat';
        icon      = Icons.warning_amber_rounded;
        break;
      default: // dikumpulkan
        bg        = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF5A623);
        label     = 'Menunggu Penilaian';
        icon      = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: textColor),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: textColor, fontFamily: 'Poppins')),
      ]),
    );
  }
}