import 'package:flutter/material.dart';

class TugasInfoCard extends StatelessWidget {
  final String judulTugas;
  final String deskripsiTugas;
  final String deadline;
  final String namaMapel;

  const TugasInfoCard({
    super.key,
    required this.judulTugas,
    required this.deskripsiTugas,
    required this.deadline,
    required this.namaMapel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Deadline badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time_rounded,
                size: 13, color: Color(0xFFE53935)),
            const SizedBox(width: 5),
            Text('Deadline: $deadline',
                style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                    fontFamily: 'Poppins')),
          ]),
        ),
        const SizedBox(height: 10),
        Text(judulTugas,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        Text(deskripsiTugas,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555),
                fontFamily: 'Poppins', height: 1.6)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.menu_book_outlined,
              size: 14, color: Color(0xFF2E7D32)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(namaMapel,
                style: const TextStyle(fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins')),
          ),
        ]),
      ]),
    );
  }
}