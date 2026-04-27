import 'package:flutter/material.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  static const List<_NotifData> _notifs = [
    _NotifData(icon: Icons.assignment_outlined, iconBg: Color(0xFFFFF3E0), iconColor: Color(0xFFF5A623),
        title: 'Tugas Baru - IPAS', body: 'Guru telah mengupload tugas baru: "Sel dan Jaringan Makhluk Hidup"', time: '10 menit yang lalu', isUnread: true, actionLabel: 'Lihat Tugas'),
    _NotifData(icon: Icons.qr_code_scanner_rounded, iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32),
        title: 'Presensi Dibuka', body: 'Guru membuka presensi untuk Matematika - Hari ini', time: '1 jam yang lalu', isUnread: true, actionLabel: 'Presensi Sekarang'),
    _NotifData(icon: Icons.timer_outlined, iconBg: Color(0xFFFCE4EC), iconColor: Color(0xFFE91E63),
        title: 'Deadline Besok!', body: 'Tugas "Bahasa Indonesia Bab 3" deadline besok jam 23:59', time: '3 jam yang lalu', isUnread: false),
    _NotifData(icon: Icons.menu_book_outlined, iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32),
        title: 'Materi Baru - Matematika', body: 'Guru mengupload materi baru: "Persamaan Kuadrat"', time: 'Kemarin', isUnread: false),
    _NotifData(icon: Icons.quiz_outlined, iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1E88E5),
        title: 'Kuis Tersedia - IPAS', body: 'Kuis Evaluasi Bab 1 sudah tersedia. Segera kerjakan!', time: '2 hari lalu', isUnread: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tandai dibaca',
              style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32),
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: _notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _NotifCard(data: _notifs[i]),
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body, time;
  final bool isUnread;
  final String? actionLabel;

  const _NotifData({required this.icon, required this.iconBg, required this.iconColor,
      required this.title, required this.body, required this.time,
      required this.isUnread, this.actionLabel});
}

class _NotifCard extends StatelessWidget {
  final _NotifData data;
  const _NotifCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: data.iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(data.icon, color: data.iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Text(data.body,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                  fontFamily: 'Poppins', height: 1.5)),
            const SizedBox(height: 4),
            Text(data.time,
              style: const TextStyle(fontSize: 10, color: Color(0xFFBBBBBB), fontFamily: 'Poppins')),
            if (data.actionLabel != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(data.actionLabel!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ]),
        ),
        if (data.isUnread)
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF44336)),
          ),
      ]),
    );
  }
}