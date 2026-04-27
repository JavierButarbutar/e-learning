import 'package:flutter/material.dart';

class InformasiPribadiScreen extends StatefulWidget {
  const InformasiPribadiScreen({super.key});

  @override
  State<InformasiPribadiScreen> createState() =>
      _InformasiPribadiScreenState();
}

class _InformasiPribadiScreenState extends State<InformasiPribadiScreen> {
  final _namaCtrl = TextEditingController(text: 'Muhammad Ibnu');
  final _alamatCtrl = TextEditingController();

  bool _isSaving = false;

  static const String _nisn = '241662638798273';
  static const String _kelas = '10 TKJ 1';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Informasi berhasil disimpan',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topSafe = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32),
            padding: EdgeInsets.fromLTRB(16, topSafe + 12, 16, 18),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Informasi Pribadi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  /// FOTO (readonly)
                  Column(
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEAF4EA),
                          border: Border.all(
                            color: const Color(0xFFF5A623),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 56,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Foto profil tidak dapat diubah',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// CARD FORM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFEAEAEA),
                      ),
                    ),
                    child: Column(
                      children: [
                        _EditableField(
                          label: 'Nama Lengkap',
                          controller: _namaCtrl,
                          hint: 'Masukkan nama lengkap',
                        ),

                        const _DividerLine(),

                        _ReadonlyField(
                          label: 'NISN (Tidak dapat diubah)',
                          value: _nisn,
                        ),

                        const _DividerLine(),

                        _ReadonlyField(
                          label: 'Kelas dan Jurusan',
                          value: _kelas,
                        ),

                        const _DividerLine(),

                        _EditableField(
                          label: 'Alamat',
                          controller: _alamatCtrl,
                          hint: 'Masukkan alamat lengkap',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        disabledBackgroundColor:
                            const Color(0xFF2E7D32).withOpacity(.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// READONLY FIELD
/// =======================================================
class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A8A8A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// EDIT FIELD
/// =======================================================
class _EditableField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A8A8A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// DIVIDER
/// =======================================================
class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 18,
      endIndent: 18,
    );
  }
}