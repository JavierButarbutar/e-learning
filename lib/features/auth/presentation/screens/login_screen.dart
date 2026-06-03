import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../provider/auth_provider.dart';
import '../../../notifikasi/data/repositories/notifikasi_repository.dart';
import '../../../guru/notifikasi/data/repositories/notifikasi_guru_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkForceLogout(); // tambah
  }

  void _checkForceLogout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args?['forceLogout'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir, akun digunakan di perangkat lain'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _loadSavedCredentials() async {
    final provider = context.read<AuthProvider>();
    await provider.loadSavedCredentials();

    if (!mounted) return;
    final savedEmail = provider.savedEmail;
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailCtrl.text = savedEmail;
        _remember = true;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final role = await context.read<AuthProvider>().login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      remember: _remember,
    );

    if (!mounted) return;

    if (role == null) {
      final error = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      if (role == 'guru') {
        await NotifikasiGuruRepository.updateFcmToken(fcmToken);
      } else {
        await NotifikasiRepository.updateFcmToken(fcmToken);
      }
    }

    Navigator.pushReplacementNamed(
      context,
      role == 'guru' ? '/home-guru' : '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return AuthScaffold(
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masuk ke akunmu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Email',
                  hint: 'Masukkan email kamu',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Password',
                  hint: 'Masukkan Password',
                  controller: _passCtrl,
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _remember,
                          onChanged: (v) =>
                              setState(() => _remember = v ?? false),
                          activeColor: const Color(0xFF2E7D32),
                        ),
                        const Text(
                          'Ingat Saya',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppButton(
                  text: 'Masuk',
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _login,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}
