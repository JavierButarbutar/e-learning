import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool dark;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.12) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: dark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF888888),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: dark
                      ? Colors.white.withOpacity(0.6)
                      : const Color(0xFF888888),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : const Color(0xFF1A1A1A),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}