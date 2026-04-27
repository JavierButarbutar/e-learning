import 'package:flutter/material.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailCtrl = TextEditingController(text: 'Ibnu.@student.ac.id');
  final _emailBaruCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _isSaving = false;
  bool _showGantiForm = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailBaruCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (_emailBaruCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email baru'),
            backgroundColor: Colors.orange));
      return;
    }
    if (_emailBaruCtrl.text != _konfirmasiCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi email tidak cocok'),
            backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() { _isSaving = false; _showGantiForm = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Email berhasil diperbarui',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // AppBar hijau
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Email saat ini ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.verified_outlined,
                            color: Color(0xFF2E7D32), size: 16),
                        SizedBox(width: 6),
                        Text('Alamat Email',
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                      ]),
                      const SizedBox(height: 10),
                      Text('Email saat ini',
                        style: const TextStyle(fontSize: 11,
                            color: Color(0xFF888888), fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Text(_emailCtrl.text,
                        style: const TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tombol ganti email ──
                if (!_showGantiForm)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showGantiForm = true),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Ganti Email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                // ── Form ganti email ──
                if (_showGantiForm) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ganti Alamat Email',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                        const SizedBox(height: 16),

                        _FieldLabel(label: 'Email Baru'),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: _emailBaruCtrl,
                          hint: 'Masukkan email baru',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        _FieldLabel(label: 'Konfirmasi Email Baru'),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: _konfirmasiCtrl,
                          hint: 'Ulangi email baru',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),

                        // Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Row(children: const [
                            Icon(Icons.info_outline_rounded,
                                color: Color(0xFFF5A623), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Link verifikasi akan dikirim ke email baru kamu.',
                                style: TextStyle(fontSize: 11,
                                    color: Color(0xFF856404),
                                    fontFamily: 'Poppins', height: 1.5)),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showGantiForm = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF888888),
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                          style: TextStyle(fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan',
                                style: TextStyle(fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
        fontFamily: 'Poppins', fontWeight: FontWeight.w600));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _InputField({required this.controller, required this.hint,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A), fontFamily: 'Poppins'),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB),
          fontFamily: 'Poppins', fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
  );
}