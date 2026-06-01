import 'package:flutter/material.dart';
import '../../data/models/notifikasi_guru_model.dart';

class NotifikasiGuruItem extends StatelessWidget {
  final NotifikasiGuruModel notif;
  final VoidCallback onTap;

  const NotifikasiGuruItem({
    super.key,
    required this.notif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead
                ? const Color(0xFFEEEEEE)
                : const Color(0xFF2E7D32).withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.judul,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: notif.isRead
                          ? FontWeight.w600
                          : FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.isi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (notif.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatWaktu(notif.createdAt!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2E7D32),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
