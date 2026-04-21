import 'package:flutter/material.dart';

const _kGreen     = Color(0xFF2E7D32);
const _kGreenDark = Color(0xFF1B5E20);
const _kGold      = Color(0xFFF5A623);
const _kFieldBg   = Color(0xFFF5F5F5);
const _kFieldBdr  = Color(0xFFE0E0E0);
const _kTextDark  = Color(0xFF1A1A1A);
const _kTextGray  = Color(0xFF888888);
const _kTextHint  = Color(0xFF9E9E9E);

// ── Green header dengan logo + nama sekolah ──────────────────
class GreenHeader extends StatelessWidget {
  const GreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kGreen,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(children: [
        // Logo
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: _kGold, width: 2.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipOval(
            child: Image.asset('assets/images/logo_sekolah.png',
                fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
        const Text('SMK Negeri 1 Tamanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins', letterSpacing: 0.2)),
        const SizedBox(height: 3),
        Text('E-Learning Digital',
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75),
              fontFamily: 'Poppins')),
      ]),
    );
  }
}

// ── Layered scaffold: green header + white card ───────────────
// Menggunakan Stack agar card putih overlap ke header hijau
// tanpa margin negatif (tidak didukung Flutter).
class AuthScaffold extends StatelessWidget {
  final Widget body;
  final bool showBack;

  const AuthScaffold({super.key, required this.body, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Back button (opsional)
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),

            // Header hijau
            const GreenHeader(),

            // Card putih rounded atas — langsung di bawah header,
            // tidak perlu margin negatif sama sekali
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

// ── Form field hijau abu-abu ──────────────────────────────────
class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: _kTextDark, fontFamily: 'Poppins')),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 13, color: _kTextDark, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _kTextHint, fontFamily: 'Poppins'),
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: _kFieldBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kFieldBdr)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kFieldBdr)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kGreen, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red)),
        ),
      ),
    ]);
  }
}

// ── Tombol hijau utama ────────────────────────────────────────
class GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const GreenButton({super.key, required this.label,
      required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      ),
    );
  }
}

// ── Footer "Koneksi aman" ─────────────────────────────────────
class SecureFooter extends StatelessWidget {
  const SecureFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFFBBBBBB)),
      const SizedBox(width: 5),
      Text('KONEKSI AMAN & TERENKRIPSI',
        style: TextStyle(fontSize: 9, color: Colors.grey.shade400,
            letterSpacing: 0.6, fontFamily: 'Poppins')),
    ]);
  }
}

// ── Icon prefix untuk field ───────────────────────────────────
Widget fieldIcon(IconData icon) =>
    Icon(icon, size: 18, color: const Color(0xFF9E9E9E));