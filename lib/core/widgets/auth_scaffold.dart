import 'package:flutter/material.dart';
import 'app_textfield.dart';
import 'app_button.dart';

// ─────────────────────────────────────────────
// COLOR (tetap sesuai desain kamu)
// ─────────────────────────────────────────────
const _kGreen     = Color(0xFF2E7D32);
const _kGold      = Color(0xFFF5A623);
const _kTextGray  = Color(0xFF888888);

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class GreenHeader extends StatelessWidget {
  const GreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kGreen,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _kGold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_sekolah.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SMK Negeri 1 Tamanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'E-Learning Digital',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.75),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AUTH SCAFFOLD (tidak berubah layout)
// ─────────────────────────────────────────────
class AuthScaffold extends StatelessWidget {
  final Widget body;
  final bool showBack;

  const AuthScaffold({
    super.key,
    required this.body,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kGreen,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

            const GreenHeader(),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────
class SecureFooter extends StatelessWidget {
  const SecureFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 12,
          color: Color(0xFFBBBBBB),
        ),
        const SizedBox(width: 5),
        Text(
          'KONEKSI AMAN & TERENKRIPSI',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade400,
            letterSpacing: 0.6,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ICON HELPER
// ─────────────────────────────────────────────
Widget fieldIcon(IconData icon) {
  return Icon(
    icon,
    size: 18,
    color: const Color(0xFF9E9E9E),
  );
}