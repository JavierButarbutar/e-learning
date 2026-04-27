import 'package:flutter/material.dart';

class UploadTugasScreen extends StatefulWidget {
  final String judulTugas;
  final String deskripsiTugas;
  final String deadline;
  final String namaMapel;

  const UploadTugasScreen({
    super.key,
    this.judulTugas = 'Tugas Makalah Biologi',
    this.deskripsiTugas =
        'Buat makalah tentang sistem reproduksi manusia. Minimal 5 halaman, sertakan gambar dan daftar pustaka.',
    this.deadline = '11 Maret 2025, 23:59',
    this.namaMapel = 'Ilmu Pengetahuan Alam dan Sosial',
  });

  @override
  State<UploadTugasScreen> createState() => _UploadTugasScreenState();
}

class _UploadTugasScreenState extends State<UploadTugasScreen> {
  String? _namaFile;
  String? _ukuranFile;
  final _catatanCtrl = TextEditingController();
  bool _isLoading = false;
  bool _berhasilDiserahkan = false;

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _pilihFile() {
    // TODO: Ganti dengan file_picker package
    // FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','doc','docx'])
    setState(() {
      _namaFile = 'Makalah_Biologi_Ibnu.pdf';
      _ukuranFile = '2.4 MB';
    });
  }

  void _hapusFile() => setState(() { _namaFile = null; _ukuranFile = null; });

  void _serahkan() async {
    if (_namaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih file tugas terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // TODO: API upload
    if (!mounted) return;
    setState(() { _isLoading = false; _berhasilDiserahkan = true; });
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 40),
            ),
            const SizedBox(height: 18),
            const Text('Tugas Berhasil Diserahkan!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text('${widget.judulTugas} telah dikirim ke guru.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888),
                  fontFamily: 'Poppins', height: 1.5)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke materi
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Materi',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700, fontSize: 14)),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Upload Tugas',
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
                // ── Card info tugas ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deadline
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Color(0xFFE53935)),
                          const SizedBox(width: 5),
                          Text('Deadline: ${widget.deadline}',
                            style: const TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE53935),
                                fontFamily: 'Poppins')),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.judulTugas,
                        style: const TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'Poppins')),
                      const SizedBox(height: 6),
                      Text(widget.deskripsiTugas,
                        style: const TextStyle(fontSize: 13,
                            color: Color(0xFF555555),
                            fontFamily: 'Poppins', height: 1.6)),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.menu_book_outlined,
                            size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(widget.namaMapel,
                            style: const TextStyle(fontSize: 12,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins')),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── File Tugas ──
                const Text('File Tugas Anda',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                const SizedBox(height: 10),

                if (_namaFile == null)
                  GestureDetector(
                    onTap: _pilihFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF2E7D32),
                            style: BorderStyle.solid,
                            width: 1.5),
                      ),
                      child: Column(children: [
                        Container(
                          width: 52, height: 52,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE8F5E9),
                          ),
                          child: const Icon(Icons.upload_file_outlined,
                              color: Color(0xFF2E7D32), size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text('Klik untuk upload file',
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                              fontFamily: 'Poppins')),
                        const SizedBox(height: 4),
                        const Text('PDF, DOC, DOCX (Maks. 10 MB)',
                          style: TextStyle(fontSize: 11,
                              color: Color(0xFF888888),
                              fontFamily: 'Poppins')),
                      ]),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf_outlined,
                            color: Color(0xFFE53935), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_namaFile!,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                  fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis),
                            Text(_ukuranFile!,
                              style: const TextStyle(fontSize: 11,
                                  color: Color(0xFF888888),
                                  fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _hapusFile,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF5F5F5),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: Color(0xFF888888)),
                        ),
                      ),
                    ]),
                  ),

                const SizedBox(height: 20),

                // ── Catatan opsional ──
                Row(children: const [
                  Text('Catatan (Opsional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                  SizedBox(width: 6),
                  Text('opsional',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888),
                        fontFamily: 'Poppins')),
                ]),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: TextField(
                    controller: _catatanCtrl,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Poppins',
                        color: Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'Tambahkan pesan ke guru...',
                      hintStyle: const TextStyle(fontSize: 13,
                          color: Color(0xFFBBBBBB), fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Tombol serahkan ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _serahkan,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isLoading ? 'Mengirim...' : 'Serahkan Tugas',
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}