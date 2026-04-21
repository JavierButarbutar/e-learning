import 'package:flutter/material.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure   = true;
  bool _remember  = false;
  bool _loading   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  await Future.delayed(const Duration(milliseconds: 1500));

  if (!mounted) return;

  setState(() => _loading = false);

  Navigator.pushReplacementNamed(context, '/home');
}

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            const Text('Login',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            const Text('Login ke akunmu',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
            const SizedBox(height: 20),

            // Email
            AuthField(
              label: 'Email',
              hint: 'Masukkan Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefix: fieldIcon(Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            AuthField(
              label: 'Password',
              hint: 'Masukkan Password',
              obscure: _obscure,
              controller: _passCtrl,
              prefix: fieldIcon(Icons.lock_outline_rounded),
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    size: 20, color: const Color(0xFF9E9E9E)),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                if (v.length < 6) return 'Minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Remember me + Lupa password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  SizedBox(
                    width: 18, height: 18,
                    child: Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                      activeColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Ingatkan Saya',
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555),
                        fontFamily: 'Poppins')),
                ]),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32)),
                  child: const Text('Lupa Password?',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tombol masuk
            GreenButton(label: 'Masuk Sekarang', onTap: _login, isLoading: _loading),
            const SizedBox(height: 28),

            // Footer
            const SecureFooter(),
          ],
        ),
      ),
    );
  }
}