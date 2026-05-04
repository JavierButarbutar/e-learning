import 'package:flutter/material.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/network/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // ================= NEXT =================
  void _next() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    final email = _emailCtrl.text.trim();

    // 🔍 STEP 1: CEK EMAIL
    final check = await ApiService.checkEmail(email: email);

    if (check['success'] != true) {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(check['message']),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 📩 STEP 2: KIRIM OTP
    final otp = await ApiService.sendOtp(email: email);

    setState(() => _loading = false);

    if (otp['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otp['message']),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ PINDAH KE OTP SCREEN
    Navigator.pushNamed(
      context,
      '/otp',
      arguments: {'email': email},
    );

  } catch (e) {
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lupa Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Masukkan email yang terdaftar untuk menerima kode OTP',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 24),

            // EMAIL FIELD
            AppTextField(
              label: 'Email',
              hint: 'Masukkan email terdaftar',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Email wajib diisi';
                }

                final emailRegex = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );

                if (!emailRegex.hasMatch(v)) {
                  return 'Format email tidak valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // BUTTON
            AppButton(
              text: 'Selanjutnya',
              onPressed: _next,
              isLoading: _loading,
            ),

            const SizedBox(height: 28),

            const SecureFooter(),
          ],
        ),
      ),
    );
  }
}