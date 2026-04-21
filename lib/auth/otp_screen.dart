import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/auth_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  bool _loading = false;
  int _seconds  = 180;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nodes[0]);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { t.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  void _resend() {
    setState(() { _seconds = 180; for (var c in _ctls) c.clear(); });
    FocusScope.of(context).requestFocus(_nodes[0]);
    _timer?.cancel();
    _startTimer();
  }

  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _verify() async {
    final otp = _ctls.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Masukkan 4 digit kode OTP'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _loading = false);
    // TODO: Verifikasi OTP via API
    Navigator.pushNamed(context, '/reset-password');
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _ctls) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final email = args?['email'] as String? ?? '***@smkn1tamanan.sch.id';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // ── Header putih dengan logo ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(children: [
              // Logo
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF5A623), width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      blurRadius: 10, offset: const Offset(0, 3))],
                ),
                padding: const EdgeInsets.all(6),
                child: ClipOval(
                  child: Image.asset('assets/images/logo_sekolah.png',
                      fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              const Text('E-LEARNING DIGITAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32), letterSpacing: 1.2, fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              const Text('SMKN 1 TAMANAN',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20), letterSpacing: 0.5, fontFamily: 'Poppins')),
            ]),
          ),

          // ── Body abu-abu ──
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                // OTP card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(children: [
                    const Text('Verifikasi OTP',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Text(
                      'Kami telah mengirimkan kode verifikasi 4\ndigit ke Email terdaftar Anda.\n$email',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF777777),
                          fontFamily: 'Poppins', height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    // OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) => _OtpBox(
                        controller: _ctls[i],
                        focusNode: _nodes[i],
                        onChanged: (val) {
                          if (val.length == 1 && i < 3) {
                            FocusScope.of(context).requestFocus(_nodes[i + 1]);
                          } else if (val.isEmpty && i > 0) {
                            FocusScope.of(context).requestFocus(_nodes[i - 1]);
                          }
                          setState(() {});
                        },
                      )),
                    ),
                    const SizedBox(height: 16),

                    // Timer
                    if (_seconds > 0)
                      Text(_timerLabel,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                    const SizedBox(height: 10),

                    // Resend
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Tidak menerima kode? ',
                        style: TextStyle(fontSize: 12, color: Color(0xFF666666),
                            fontFamily: 'Poppins')),
                      GestureDetector(
                        onTap: _seconds == 0 ? _resend : null,
                        child: Text('Kirim Ulang',
                          style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: _seconds == 0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF999999))),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    GreenButton(label: 'Verifikasi', onTap: _verify,
                        isLoading: _loading),
                  ]),
                ),

                const SizedBox(height: 14),

                // Security card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2E7D32),
                      ),
                      child: const Icon(Icons.lock_outline_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sistem Keamanan',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20), fontFamily: 'Poppins')),
                          SizedBox(height: 2),
                          Text('Keamanan data Anda adalah prioritas utama\nkami di SMKN 1 Tamanan',
                            style: TextStyle(fontSize: 11, color: Color(0xFF388E3C),
                                fontFamily: 'Poppins', height: 1.5)),
                        ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),),
        ]),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return Container(
      width: 58, height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
            color: Color(0xFF2E7D32), fontFamily: 'Poppins'),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: filled ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: filled ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                  width: filled ? 2 : 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: filled ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                  width: filled ? 2 : 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}