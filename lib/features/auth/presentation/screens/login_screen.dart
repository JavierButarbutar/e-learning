import 'package:flutter/material.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';

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
  bool _loading = false;

  String _role = 'siswa';

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

    if (_role == 'guru') {
      Navigator.pushReplacementNamed(context, '/home-guru');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: Color(0xFF1A1A1A),
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

            _RoleToggle(
              selected: _role,
              onChanged: (r) {
                setState(() {
                  _role = r;
                  _emailCtrl.clear();
                  _passCtrl.clear();
                });
              },
            ),

            const SizedBox(height: 20),

            AppTextField(
              label: _role == 'guru' ? 'Email Guru' : 'Email Siswa',
              hint: _role == 'guru'
                  ? 'contoh@tutor.id'
                  : 'contoh@student.ac.id',
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
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
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
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _remember,
                        onChanged: (v) {
                          setState(() => _remember = v ?? false);
                        },
                        activeColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Ingatkan Saya',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/forgot-password',
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            AppButton(
              text: _role == 'guru'
                  ? 'Masuk sebagai Guru'
                  : 'Masuk sebagai Siswa',
              isLoading: _loading,
              onPressed: _login,
            ),

            const SizedBox(height: 28),

            const SecureFooter(),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TOGGLE ROLE
// =====================================================

class _RoleToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _RoleBtn(
            label: 'Siswa',
            icon: Icons.school_outlined,
            active: selected == 'siswa',
            onTap: () => onChanged('siswa'),
          ),
          _RoleBtn(
            label: 'Guru',
            icon: Icons.person_outline_rounded,
            active: selected == 'guru',
            onTap: () => onChanged('guru'),
          ),
        ],
      ),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _RoleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF2E7D32)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? Colors.white
                    : const Color(0xFF888888),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: active
                      ? Colors.white
                      : const Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}