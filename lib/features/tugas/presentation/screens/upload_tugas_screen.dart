import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../widgets/tugas_info_card.dart';
import '../../widgets/nilai_card.dart';
import '../../widgets/file_jawaban_section.dart';

class UploadTugasScreen extends StatefulWidget {
  final String idTugas;
  final String judulTugas;
  final String deskripsiTugas;
  final String deadline;
  final String namaMapel;

  const UploadTugasScreen({
    super.key,
    required this.idTugas,
    this.judulTugas    = 'Tugas',
    this.deskripsiTugas = '-',
    this.deadline      = '-',
    this.namaMapel     = '-',
  });

  @override
  State<UploadTugasScreen> createState() => _UploadTugasScreenState();
}

class _UploadTugasScreenState extends State<UploadTugasScreen> {
  // ── File baru (belum diupload) ────────────────────────────
  File?   _fileBaru;
  String? _namaFileBaru;
  String? _ukuranFileBaru;
  String? _mimeType;

  // ── Data pengumpulan dari server ──────────────────────────
  String? _fileTeruploadNama;
  String? _fileTeruploadUrl;
  bool    _sudahDinilai      = false;
  String? _statusPengumpulan;
  String? _nilai;
  String? _catatanGuru;

  final _catatanCtrl     = TextEditingController();
  bool _isLoading        = false;
  bool _isFetchingStatus = true;

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchStatusPengumpulan();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  // ── Fetch status pengumpulan ──────────────────────────────
  Future<void> _fetchStatusPengumpulan() async {
    try {
      final token    = await SharedPref.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoint.tugasSiswa),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data      = jsonDecode(response.body);
        final tugasList = data['data'] as List? ?? [];

        final tugasThis = tugasList.firstWhere(
          (t) => t['id_tugas'].toString() == widget.idTugas,
          orElse: () => null,
        );

        final pengumpulan = tugasThis?['pengumpulan'];

        if (pengumpulan != null) {
          final fileUrl = pengumpulan['file_url'] as String?;
          setState(() {
            _fileTeruploadNama = fileUrl != null
                ? Uri.decodeFull(fileUrl.split('/').last)
                : null;
            _fileTeruploadUrl  = fileUrl;
            _statusPengumpulan = pengumpulan['status'];
            _sudahDinilai      = pengumpulan['status'] == 'dinilai';
            _nilai             = pengumpulan['nilai']?.toString();
            _catatanGuru       = pengumpulan['catatan_guru'];
            if (pengumpulan['jawaban'] != null && _catatanCtrl.text.isEmpty) {
              _catatanCtrl.text = pengumpulan['jawaban'];
            }
          });
        } else {
          setState(() {
            _fileTeruploadNama = null;
            _fileTeruploadUrl  = null;
            _statusPengumpulan = null;
            _sudahDinilai      = false;
            _nilai             = null;
            _catatanGuru       = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal fetch status pengumpulan: $e');
    } finally {
      if (mounted) setState(() => _isFetchingStatus = false);
    }
  }

  // ── Pilih file ────────────────────────────────────────────
  Future<void> _pilihFile() async {
    if (_fileTeruploadNama != null || _fileBaru != null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'ppt', 'pptx'],
    );

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    final bytes  = picked.size;
    final ukuran = bytes < 1024 * 1024
        ? '${(bytes / 1024).toStringAsFixed(1)} KB'
        : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

    setState(() {
      _fileBaru       = File(picked.path!);
      _namaFileBaru   = picked.name;
      _ukuranFileBaru = ukuran;
      _mimeType       = _getMimeType(picked.extension?.toLowerCase() ?? '');
    });
  }

  String _getMimeType(String ext) {
    const map = {
      'pdf':  'application/pdf',
      'doc':  'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt':  'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'jpg':  'image/jpeg',
      'jpeg': 'image/jpeg',
      'png':  'image/png',
    };
    return map[ext] ?? 'application/octet-stream';
  }

  void _hapusFileBaru() => setState(() {
    _fileBaru = _namaFileBaru = _ukuranFileBaru = _mimeType = null;
  });

  void _hapusFileTerupload() {
    if (_sudahDinilai) {
      _showSnackbar('Tugas sudah dinilai, tidak dapat diubah', Colors.red);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus File?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          'File yang sudah diupload akan dihapus. Kamu bisa upload file baru setelahnya.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _fileTeruploadNama = null;
                _fileTeruploadUrl  = null;
                _statusPengumpulan = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Upload ke API ─────────────────────────────────────────
  Future<void> _serahkan() async {
    if (_fileBaru == null && _catatanCtrl.text.trim().isEmpty) {
      _showSnackbar('Pilih file atau isi catatan terlebih dahulu', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token   = await SharedPref.getToken();
      final uri     = Uri.parse(ApiEndpoint.uploadTugas(widget.idTugas));
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

      if (_catatanCtrl.text.trim().isNotEmpty) {
        request.fields['jawaban'] = _catatanCtrl.text.trim();
      }

      if (_fileBaru != null && _mimeType != null) {
        final mime = _mimeType!.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'file_jawaban',
          _fileBaru!.path,
          filename: _namaFileBaru,
          contentType: MediaType(mime[0], mime[1]),
        ));
      }

      final response = await http.Response.fromStream(await request.send());
      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final p       = data['data'];
        final fileUrl = p['file_url'] as String?;
        setState(() {
          _fileTeruploadNama = fileUrl != null
              ? Uri.decodeFull(fileUrl.split('/').last)
              : _namaFileBaru;
          _fileTeruploadUrl  = fileUrl;
          _statusPengumpulan = p['status'];
          _sudahDinilai      = p['status'] == 'dinilai';
          _fileBaru = _namaFileBaru = _ukuranFileBaru = _mimeType = null;
        });
        _showSuccessDialog();
      } else {
        _showSnackbar(data['message'] ?? 'Gagal mengirim tugas', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
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
                  shape: BoxShape.circle, color: Color(0xFFE8F5E9)),
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bisaSerahkan = _fileBaru != null &&
        _fileTeruploadNama == null &&
        !_sudahDinilai;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // ── AppBar ─────────────────────────────────────────
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
            const Text('Upload Tugas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
          ]),
        ),

        // ── Body ───────────────────────────────────────────
        Expanded(
          child: _isFetchingStatus
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Info tugas
                      TugasInfoCard(
                        judulTugas:    widget.judulTugas,
                        deskripsiTugas: widget.deskripsiTugas,
                        deadline:      widget.deadline,
                        namaMapel:     widget.namaMapel,
                      ),

                      // Nilai (jika sudah dinilai)
                      if (_sudahDinilai && _nilai != null) ...[
                        const SizedBox(height: 14),
                        NilaiCard(nilai: _nilai!, catatanGuru: _catatanGuru),
                      ],

                      // Banner menunggu penilaian
                      if (!_sudahDinilai && _fileTeruploadNama != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Row(children: const [
                            Icon(Icons.hourglass_empty_rounded,
                                size: 18, color: Color(0xFFF5A623)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tugasmu sudah dikirim dan sedang menunggu penilaian dari guru.',
                                style: TextStyle(fontSize: 12,
                                    color: Color(0xFF856404),
                                    fontFamily: 'Poppins', height: 1.4),
                              ),
                            ),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Section file jawaban
                      FileJawabanSection(
                        fileTeruploadNama:   _fileTeruploadNama,
                        fileTeruploadUrl:    _fileTeruploadUrl,
                        fileBaru:            _fileBaru,
                        namaFileBaru:        _namaFileBaru,
                        ukuranFileBaru:      _ukuranFileBaru,
                        sudahDinilai:        _sudahDinilai,
                        statusPengumpulan:   _statusPengumpulan,
                        onPilihFile:         _pilihFile,
                        onHapusFileBaru:     _hapusFileBaru,
                        onHapusFileTerupload: _hapusFileTerupload,
                      ),

                      const SizedBox(height: 20),

                      // Catatan
                      Row(children: const [
                        Text('Catatan',
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                fontFamily: 'Poppins')),
                        SizedBox(width: 6),
                        Text('opsional',
                            style: TextStyle(fontSize: 11,
                                color: Color(0xFF888888),
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
                          enabled: !_sudahDinilai,
                          style: const TextStyle(fontSize: 13,
                              fontFamily: 'Poppins',
                              color: Color(0xFF333333)),
                          decoration: InputDecoration(
                            hintText: _sudahDinilai
                                ? 'Tugas sudah dinilai guru'
                                : 'Tambahkan pesan ke guru...',
                            hintStyle: const TextStyle(fontSize: 13,
                                color: Color(0xFFBBBBBB),
                                fontFamily: 'Poppins'),
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

                      // Tombol serahkan
                      if (bisaSerahkan)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _serahkan,
                            icon: _isLoading
                                ? const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              _isLoading ? 'Mengirim...' : 'Serahkan Tugas',
                              style: const TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins'),
                            ),
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