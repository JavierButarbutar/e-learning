import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 24),
          width: double.infinity,
          child: Row(children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFF5A623), width: 2)),
              child: const Center(child: Text('MI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32), fontFamily: 'Poppins')))),
            const SizedBox(width: 14),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Muhammad Ibnu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
              SizedBox(height: 2),
              Text('Kelas X-A · SMKN 1 Tamanan', style: TextStyle(fontSize: 11, color: Color(0xB3FFFFFF), fontFamily: 'Poppins')),
            ]),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _SettingsTile(icon: Icons.person_outline, label: 'Profil Saya', onTap: (){}),
              _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifikasi', onTap: (){}),
              _SettingsTile(icon: Icons.lock_outline, label: 'Ubah Password', onTap: (){}),
              _SettingsTile(icon: Icons.help_outline, label: 'Bantuan', onTap: (){}),
              _SettingsTile(icon: Icons.info_outline, label: 'Tentang Aplikasi', onTap: (){}),
              const SizedBox(height: 8),
              _SettingsTile(icon: Icons.logout_rounded, label: 'Keluar', onTap: (){
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }, isLogout: true),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isLogout;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.isLogout = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
        child: Row(children: [
          Icon(icon, size: 20, color: isLogout ? const Color(0xFFE53935) : const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: isLogout ? const Color(0xFFE53935) : const Color(0xFF1A1A1A))),
          const Spacer(),
          if (!isLogout) const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
        ]),
      ),
    );
  }
}