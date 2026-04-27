import 'package:flutter/material.dart';
import 'informasi_pribadi_screen.dart';
import 'email_screen.dart';
import 'ubah_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header hijau dengan info profil ──
          _buildHeader(context),

          // ── Body putih rounded ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card statistik mata pelajaran
                  _StatCard(),

                  const SizedBox(height: 24),

                  // Pengaturan Akun
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text('Pengaturan Akun',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins',
                      )),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _MenuTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Informasi Pribadi',
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => const InformasiPribadiScreen())),
                          ),
                          const Divider(height: 1, indent: 56,
                              color: Color(0xFFF0F0F0)),
                          _MenuTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => const EmailScreen())),
                          ),
                          const Divider(height: 1, indent: 56,
                              color: Color(0xFFF0F0F0)),
                          _MenuTile(
                            icon: Icons.lock_outline_rounded,
                            label: 'Ubah Password',
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => const UbahPasswordScreen())),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Keluar Akun
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout_rounded,
                                color: Color(0xFFE53935), size: 20),
                            SizedBox(width: 8),
                            Text('Keluar Akun',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: Color(0xFFE53935), fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 28),
      child: Column(
        children: [
          // Judul halaman
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Profil Saya',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white, fontFamily: 'Poppins',
              )),
          ),
          const SizedBox(height: 20),

          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF5A623), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar_placeholder.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.person_rounded,
                          size: 48, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama
          const Text('Muhammad Ibnu',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins',
            )),
          const SizedBox(height: 4),
          Text('Kelas 10 TKJ 1',
            style: TextStyle(
              fontSize: 13, color: Colors.white.withOpacity(0.75),
              fontFamily: 'Poppins',
            )),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800,
              fontSize: 17)),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: Color(0xFF888888), height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
              style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
              style: TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Stat card di bawah header ─────────────────────────────────
class _StatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Transform.translate(
        offset: const Offset(0, -1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatItem(
              icon: Icons.menu_book_rounded,
              value: '12',
              label: 'Mata Pelajaran',
              iconColor: const Color(0xFF2E7D32),
              iconBg: const Color(0xFFE8F5E9),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color iconColor, iconBg;

  const _StatItem({
    required this.icon, required this.value,
    required this.label, required this.iconColor, required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
              fontFamily: 'Poppins')),
      ]),
    );
  }
}

// ── Menu tile ─────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC), size: 22),
        ]),
      ),
    );
  }
}