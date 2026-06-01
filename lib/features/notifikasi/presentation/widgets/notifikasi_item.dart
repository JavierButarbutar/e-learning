import 'package:flutter/material.dart';
import '../../data/models/notifikasi_model.dart';

class NotifikasiItem extends StatelessWidget {
  final NotifikasiModel notif;
  final VoidCallback? onTap;

  const NotifikasiItem({super.key, required this.notif, this.onTap});

  _IconConfig get _iconConfig {
    switch (notif.tipe) {
      case 'tugas_baru':
        return _IconConfig(
          Icons.assignment_outlined,
          const Color(0xFFFFF3E0),
          const Color(0xFFF5A623),
        );
      case 'presensi_dibuka':
        return _IconConfig(
          Icons.qr_code_scanner_rounded,
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        );
      case 'materi_baru':
        return _IconConfig(
          Icons.menu_book_outlined,
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        );
      case 'kuis_baru':
        return _IconConfig(
          Icons.quiz_outlined,
          const Color(0xFFE3F2FD),
          const Color(0xFF1E88E5),
        );
      default:
        return _IconConfig(
          Icons.notifications_outlined,
          const Color(0xFFF3E5F5),
          const Color(0xFF7B1FA2),
        );
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _iconConfig;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cfg.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(cfg.icon, color: cfg.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.judul,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.isi,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notif.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFBBBBBB),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF44336),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconConfig {
  final IconData icon;
  final Color bg, color;
  const _IconConfig(this.icon, this.bg, this.color);
}
