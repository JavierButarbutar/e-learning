import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // Header profil
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 24),
          width: double.infinity,
          child: Row(children: [
            Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF5A623), width: 2.5),
              ),
              child: const Center(
                child: Text('MI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 16),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Muhammad Ibnu',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
              SizedBox(height: 3),
              Text('Kelas X-A · SMKN 1 Tamanan',
                style: TextStyle(fontSize: 12, color: Color(0xB3FFFFFF),
                    fontFamily: 'Poppins')),
            ]),
          ]),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _SettingsTile(icon: Icons.person_outline_rounded,      label: 'Profil Saya',       onTap: () {}),
              _SettingsTile(icon: Icons.notifications_outlined,       label: 'Notifikasi',         onTap: () {}),
              _SettingsTile(icon: Icons.lock_outline_rounded,         label: 'Ubah Password',      onTap: () {}),
              _SettingsTile(icon: Icons.help_outline_rounded,         label: 'Bantuan',            onTap: () {}),
              _SettingsTile(icon: Icons.info_outline_rounded,         label: 'Tentang Aplikasi',   onTap: () {}),
              const SizedBox(height: 6),
              _SettingsTile(icon: Icons.logout_rounded, label: 'Keluar', isLogout: true,
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _SettingsTile({
    required this.icon, required this.label,
    required this.onTap, this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isLogout ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20,
              color: isLogout ? const Color(0xFFE53935) : const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 14),
          Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: isLogout ? const Color(0xFFE53935) : const Color(0xFF1A1A1A))),
          const Spacer(),
          if (!isLogout)
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 22),
        ]),
      ),
    );
  }
}