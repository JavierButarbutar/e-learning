import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/shared_pref.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _lamaCtrl = TextEditingController();
  final _baruCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();

  bool _showLama = false;
  bool _showBaru = false;
  bool _showKonf = false;
  bool _isSaving = false;

  int _strength = 0;

  @override
  void initState() {
    super.initState();

    // 🔥 penting supaya UI update realtime
    _baruCtrl.addListener(() {
      _checkStrength(_baruCtrl.text);
    });
  }

  @override
  void dispose() {
    _lamaCtrl.dispose();
    _baruCtrl.dispose();
    _konfCtrl.dispose();
    super.dispose();
  }

  void _checkStrength(String val) {
    int s = 0;
    if (val.length >= 8) s++;
    if (val.contains(RegExp(r'[A-Z]'))) s++;
    if (val.contains(RegExp(r'[0-9]'))) s++;
    if (val.contains(RegExp(r'[!@#\$%^&*]'))) s++;

    setState(() => _strength = s);
  }

  Color _strengthColor(int idx) {
    if (_strength <= idx) return const Color(0xFFEEEEEE);
    if (_strength == 1) return const Color(0xFFE53935);
    if (_strength == 2) return const Color(0xFFF5A623);
    if (_strength == 3) return const Color(0xFF1E88E5);
    return const Color(0xFF2E7D32);
  }

  String _strengthLabel() {
    switch (_strength) {
      case 1:
        return 'Lemah';
      case 2:
        return 'Cukup';
      case 3:
        return 'Kuat';
      case 4:
        return 'Sangat Kuat';
      default:
        return '';
    }
  }

  Future<void> _simpan() async {
    if (_lamaCtrl.text.isEmpty ||
        _baruCtrl.text.isEmpty ||
        _konfCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_baruCtrl.text != _konfCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_strength < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password terlalu lemah'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await SharedPref.getToken(); // ⚠️ sesuaikan dengan project kamu

      final res = await ApiService.updatePassword(
        token: token ?? '',
        oldPassword: _lamaCtrl.text,
        newPassword: _baruCtrl.text,
      );

      setState(() => _isSaving = false);

      if (res['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal mengubah password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(Icons.lock_open_rounded,
                  color: Color(0xFF2E7D32), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password Berhasil Diubah!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text('Login Ulang'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ubah Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Icon kunci
              const SizedBox(height: 8),
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF2E7D32), size: 34),
              ),
              const SizedBox(height: 10),
              const Text('Buat Password Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              const Text('Password minimal 8 karakter dengan\nhuruf besar, angka, dan simbol',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF888888),
                    fontFamily: 'Poppins', height: 1.5)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  _PassField(
                    label: 'Password Saat Ini',
                    controller: _lamaCtrl,
                    show: _showLama,
                    onToggle: () =>
                        setState(() => _showLama = !_showLama),
                  ),

                  const Divider(),

                  _PassField(
                    label: 'Password Baru',
                    controller: _baruCtrl,
                    show: _showBaru,
                    onToggle: () =>
                        setState(() => _showBaru = !_showBaru),
                  ),

                  if (_baruCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Row(children: [
                      ...List.generate(4, (i) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                            height: 5,
                            decoration: BoxDecoration(
                              color: _strengthColor(i),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),

                      Text(
                        _strengthLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _strength == 0
                              ? Colors.grey
                              : _strengthColor(_strength - 1),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 4),

                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StrengthTip('≥ 8 karakter',
                            _baruCtrl.text.length >= 8),
                        _StrengthTip('Huruf besar',
                            _baruCtrl.text.contains(RegExp(r'[A-Z]'))),
                        _StrengthTip('Angka',
                            _baruCtrl.text.contains(RegExp(r'[0-9]'))),
                        _StrengthTip('Simbol (!@#\$)',
                            _baruCtrl.text
                                .contains(RegExp(r'[!@#\$%^&*]'))),
                      ],
                    ),
                  ],

                  const Divider(),

                  _PassField(
                    label: 'Konfirmasi Password Baru',
                    controller: _konfCtrl,
                    show: _showKonf,
                    onToggle: () =>
                        setState(() => _showKonf = !_showKonf),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Password Baru'),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _PassField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;

  const _PassField({
    required this.label,
    required this.controller,
    required this.show,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextField(
            controller: controller,
            obscureText: !show,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(show ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
        ],
      );
}

class _StrengthTip extends StatelessWidget {
  final String label;
  final bool met;

  const _StrengthTip(this.label, this.met);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 3),
          Text(label),
        ],
      );
}