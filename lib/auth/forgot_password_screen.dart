import 'package:flutter/material.dart';
import 'widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _loading = false);
    // TODO: Kirim OTP ke email, lalu navigasi ke OTP screen
    Navigator.pushNamed(context, '/otp',
        arguments: {'email': _emailCtrl.text});
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lupa Password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            const Text('gunakan akun email yg terdaftar',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
            const SizedBox(height: 24),

            AuthField(
              label: 'Email',
              hint: 'Masukkan Email yang terdaftar',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefix: fieldIcon(Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 24),

            GreenButton(label: 'Selanjutnya', onTap: _next, isLoading: _loading),
            const SizedBox(height: 28),
            const SecureFooter(),
          ],
        ),
      ),
    );
  }
}