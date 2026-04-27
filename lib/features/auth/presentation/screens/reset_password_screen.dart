import 'package:flutter/material.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConf = true;
  bool _loading = false;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (_) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password berhasil diubah!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
              'Konfirmasi Password baru',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 24),

            // PASSWORD BARU
            AppTextField(
              label: 'Password',
              hint: 'Masukkan Password Baru',
              controller: _newCtrl,
              obscureText: _obscureNew,
              prefixIcon:
                  Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew
                      ? Icons
                          .visibility_off_outlined
                      : Icons
                          .visibility_outlined,
                  size: 20,
                  color:
                      const Color(0xFF9E9E9E),
                ),
                onPressed: () {
                  setState(() {
                    _obscureNew =
                        !_obscureNew;
                  });
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Password wajib diisi';
                }

                if (v.length < 6) {
                  return 'Minimal 6 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            // KONFIRMASI PASSWORD
            AppTextField(
              label: 'Konfirmasi Password',
              hint: 'Masukkan Password',
              controller: _confCtrl,
              obscureText: _obscureConf,
              prefixIcon:
                  Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConf
                      ? Icons
                          .visibility_off_outlined
                      : Icons
                          .visibility_outlined,
                  size: 20,
                  color:
                      const Color(0xFF9E9E9E),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConf =
                        !_obscureConf;
                  });
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Konfirmasi password';
                }

                if (v != _newCtrl.text) {
                  return 'Password tidak sama';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Selanjutnya',
              isLoading: _loading,
              onPressed: _save,
            ),

            const SizedBox(height: 28),

            const SecureFooter(),
          ],
        ),
      ),
    );
  }
}