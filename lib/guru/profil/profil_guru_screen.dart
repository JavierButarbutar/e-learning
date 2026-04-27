// lib/guru/profil/profil_guru_screen.dart

import 'package:flutter/material.dart';

class ProfilGuruScreen extends StatelessWidget {
  const ProfilGuruScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // ── Header hijau ──
        Container(
          color: const Color(0xFF2E7D32),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 28),
          child: Column(children: [
            // Avatar
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF5A623), width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15),
                      blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar_guru.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_rounded,
                    size: 52, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Drs. Ahmad Subarjo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text('Guru Sains & Biologi',
              style: TextStyle(fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                  fontFamily: 'Poppins')),
          ]),
        ),

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Card menu Informasi Pribadi
              _MenuCard(
                icon: Icons.person_outline_rounded,
                label: 'Informasi Pribadi',
                sublabel: 'Detail akun & profil guru',
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const InformasiPribadiGuruScreen())),
              ),

              const SizedBox(height: 16),

              // Tombol Keluar Akun
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout_rounded,
                          color: Color(0xFFE53935), size: 20),
                      SizedBox(width: 8),
                      Text('Keluar Akun',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53935),
                            fontFamily: 'Poppins')),
                    ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
        content: const Text('Apakah kamu yakin ingin keluar?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: Color(0xFF888888))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
              style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
            child: const Text('Keluar',
              style: TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.label,
      required this.sublabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A),
                  fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Text(sublabel, style: const TextStyle(fontSize: 12,
                  color: Color(0xFF888888), fontFamily: 'Poppins')),
            ])),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC), size: 22),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INFORMASI PRIBADI GURU — READ ONLY
// ─────────────────────────────────────────────────────────────
class InformasiPribadiGuruScreen extends StatelessWidget {
  const InformasiPribadiGuruScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // AppBar
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Pengaturan Profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(height: 8),

              // Avatar (non-editable)
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F5E9),
                  border: Border.all(
                      color: const Color(0xFFF5A623), width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1),
                        blurRadius: 12, offset: const Offset(0, 3)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar_guru.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      size: 50, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Drs. Ahmad Subarjo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 3),
              const Text('NIP: 19750812 200212 1 003',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
              const SizedBox(height: 24),

              // Info fields — semua read only
              _InfoCard(items: [
                _InfoRow(label: 'Nama Lengkap', value: 'Drs. Ahmad Subarjo'),
                _InfoRow(label: 'NIP', value: '19750812 200212 1 003'),
                _InfoRow(label: 'Mata Pelajaran',
                    value: '', isChips: true,
                    chips: ['Sains', 'Biologi']),
                _InfoRow(label: 'Email',
                    value: 'ahmad.subarjo@tutor.id',
                    icon: Icons.email_outlined),
                _InfoRow(label: 'Nomor Telepon',
                    value: '+62 812 3456 7890',
                    icon: Icons.phone_outlined),
                _InfoRow(label: 'Alamat Lengkap',
                    value: 'Jl. Pendidikan No. 42, Kebayoran Baru,\nJember Utara, 12110',
                    icon: Icons.location_on_outlined),
              ]),

              const SizedBox(height: 16),

              // Info tidak bisa diubah
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFF5A623), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Informasi profil dikelola oleh admin sekolah dan tidak dapat diubah melalui aplikasi.',
                      style: TextStyle(fontSize: 12,
                          color: Color(0xFF856404),
                          fontFamily: 'Poppins', height: 1.5)),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: List.generate(items.length, (i) => Column(children: [
          items[i],
          if (i < items.length - 1)
            const Divider(height: 1, color: Color(0xFFF0F0F0),
                indent: 16, endIndent: 16),
        ])),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isChips;
  final List<String>? chips;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.isChips = false,
    this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          /// CHIP SECTION
          if (isChips && chips != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: chips!
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )

          /// NORMAL TEXT SECTION
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      icon,
                      size: 16,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}