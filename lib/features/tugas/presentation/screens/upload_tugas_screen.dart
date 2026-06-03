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

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class UploadTugasScreen extends StatefulWidget {
  final String idTugas;
  final String judulTugas;
  final String deskripsiTugas;
  final String deadline;
  final String namaMapel;

  const UploadTugasScreen({
    super.key,
    required this.idTugas,
    this.judulTugas = 'Tugas',
    this.deskripsiTugas = '-',
    this.deadline = '-',
    this.namaMapel = '-',
  });

  @override
  State<UploadTugasScreen> createState() => _UploadTugasScreenState();
}

class _UploadTugasScreenState extends State<UploadTugasScreen> {
  File? _fileBaru;
  String? _namaFileBaru;
  String? _ukuranFileBaru;
  String? _mimeType;

  String? _fileTeruploadNama;
  String? _fileTeruploadUrl;
  bool _sudahDinilai = false;
  String? _statusPengumpulan;
  String? _nilai;
  String? _catatanGuru;
  String? _fileGuruUrl;
  String? _fileGuruNama;

  final _catatanCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isFetchingStatus = true;

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

  Future<void> _fetchStatusPengumpulan() async {
    try {
      final token = await SharedPref.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoint.tugasSiswa),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tugasList = data['data'] as List? ?? [];

        final tugasThis = tugasList.firstWhere(
          (t) => t['id_tugas'].toString() == widget.idTugas,
          orElse: () => null,
        );

        final fileGuruUrl = tugasThis?['file_url'] as String?;

        final pengumpulan = tugasThis?['pengumpulan'];

        setState(() {
          _fileGuruUrl = fileGuruUrl;
          _fileGuruNama = fileGuruUrl != null
              ? Uri.decodeFull(Uri.parse(fileGuruUrl).pathSegments.last)
              : null;

          if (pengumpulan != null) {
            final fileUrl = pengumpulan['file_url'] as String?;
            _fileTeruploadNama = fileUrl != null
                ? Uri.decodeFull(Uri.parse(fileUrl).pathSegments.last)
                : null;
            _fileTeruploadUrl = fileUrl;
            _statusPengumpulan = pengumpulan['status'];
            _sudahDinilai = pengumpulan['status'] == 'dinilai';
            _nilai = pengumpulan['nilai']?.toString();
            _catatanGuru = pengumpulan['catatan_guru'];
            if (pengumpulan['jawaban'] != null && _catatanCtrl.text.isEmpty) {
              _catatanCtrl.text = pengumpulan['jawaban'];
            }
          } else {
            _fileTeruploadNama = null;
            _fileTeruploadUrl = null;
            _statusPengumpulan = null;
            _sudahDinilai = false;
            _nilai = null;
            _catatanGuru = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Gagal fetch status pengumpulan: $e');
    } finally {
      if (mounted) setState(() => _isFetchingStatus = false);
    }
  }

  Future<void> _bukaFileGuru() async {
    if (_fileGuruUrl == null) {
      _showSnackbar('File tidak tersedia', Colors.red);
      return;
    }

    try {
      _showSnackbar('Mengunduh file...', Colors.green);

      final dir = await getTemporaryDirectory();

      final fileName =
          _fileGuruNama ?? Uri.parse(_fileGuruUrl!).pathSegments.last;

      final savePath = '${dir.path}/$fileName';

      await Dio().download(_fileGuruUrl!, savePath);

      final result = await OpenFile.open(savePath);

      if (result.type != ResultType.done) {
        _showSnackbar('Tidak dapat membuka file', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Gagal membuka file: $e', Colors.red);
    }
  }

  Future<void> _pilihFile() async {
    if (_fileTeruploadNama != null || _fileBaru != null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png',
        'ppt',
        'pptx',
      ],
    );

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    final bytes = picked.size;
    final ukuran = bytes < 1024 * 1024
        ? '${(bytes / 1024).toStringAsFixed(1)} KB'
        : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

    setState(() {
      _fileBaru = File(picked.path!);
      _namaFileBaru = picked.name;
      _ukuranFileBaru = ukuran;
      _mimeType = _getMimeType(picked.extension?.toLowerCase() ?? '');
    });
  }

  String _getMimeType(String ext) {
    const map = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
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
        title: const Text(
          'Hapus File?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'File yang sudah diupload akan dihapus. Kamu bisa upload file baru setelahnya.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _fileTeruploadNama = null;
                _fileTeruploadUrl = null;
                _statusPengumpulan = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _serahkan() async {
    if (_fileBaru == null && _catatanCtrl.text.trim().isEmpty) {
      _showSnackbar(
        'Pilih file atau isi catatan terlebih dahulu',
        Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SharedPref.getToken();
      final uri = Uri.parse(ApiEndpoint.uploadTugas(widget.idTugas));
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
        request.files.add(
          await http.MultipartFile.fromPath(
            'file_jawaban',
            _fileBaru!.path,
            filename: _namaFileBaru,
            contentType: MediaType(mime[0], mime[1]),
          ),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final p = data['data'];
        final fileUrl = p['file_url'] as String?;
        setState(() {
          _fileTeruploadNama = fileUrl != null
              ? Uri.decodeFull(Uri.parse(fileUrl).pathSegments.last)
              : _namaFileBaru;
          _fileTeruploadUrl = fileUrl;
          _statusPengumpulan = p['status'];
          _sudahDinilai = p['status'] == 'dinilai';
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

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F5E9),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tugas Berhasil Diserahkan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.judulTugas} telah dikirim ke guru.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Materi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(String namaFile) {
    final ext = namaFile.split('.').last.toLowerCase();
    IconData icon;
    Color color;
    Color bgColor;

    switch (ext) {
      case 'pdf':
        icon = Icons.picture_as_pdf_outlined;
        color = const Color(0xFFE53935);
        bgColor = const Color(0xFFFFEBEE);
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description_outlined;
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow_outlined;
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image_outlined;
        color = const Color(0xFF6A1B9A);
        bgColor = const Color(0xFFF3E5F5);
        break;
      default:
        icon = Icons.insert_drive_file_outlined;
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bisaSerahkan =
        _fileBaru != null && _fileTeruploadNama == null && !_sudahDinilai;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2E7D32),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 10,
              16,
              16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Upload Tugas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isFetchingStatus
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TugasInfoCard(
                          judulTugas: widget.judulTugas,
                          deskripsiTugas: widget.deskripsiTugas,
                          deadline: widget.deadline,
                          namaMapel: widget.namaMapel,
                        ),

                        if (_fileGuruUrl != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'File Soal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _bukaFileGuru,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF1565C0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildFileIcon(_fileGuruNama ?? 'file'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _fileGuruNama ?? 'File Tugas',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A1A),
                                            fontFamily: 'Poppins',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Tap untuk membuka file',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF1565C0),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 18,
                                    color: Color(0xFF1565C0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (_sudahDinilai && _nilai != null) ...[
                          const SizedBox(height: 14),
                          NilaiCard(nilai: _nilai!, catatanGuru: _catatanGuru),
                        ],

                        if (!_sudahDinilai && _fileTeruploadNama != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFE082),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 18,
                                  color: Color(0xFFF5A623),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tugasmu sudah dikirim dan sedang menunggu penilaian dari guru.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF856404),
                                      fontFamily: 'Poppins',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        FileJawabanSection(
                          fileTeruploadNama: _fileTeruploadNama,
                          fileTeruploadUrl: _fileTeruploadUrl,
                          fileBaru: _fileBaru,
                          namaFileBaru: _namaFileBaru,
                          ukuranFileBaru: _ukuranFileBaru,
                          sudahDinilai: _sudahDinilai,
                          statusPengumpulan: _statusPengumpulan,
                          onPilihFile: _pilihFile,
                          onHapusFileBaru: _hapusFileBaru,
                          onHapusFileTerupload: _hapusFileTerupload,
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Text(
                              'Catatan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'opsional',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              color: Color(0xFF333333),
                            ),
                            decoration: InputDecoration(
                              hintText: _sudahDinilai
                                  ? 'Tugas sudah dinilai guru'
                                  : 'Tambahkan pesan ke guru...',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBBBBB),
                                fontFamily: 'Poppins',
                              ),
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

                        if (bisaSerahkan)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _serahkan,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 18),
                              label: Text(
                                _isLoading ? 'Mengirim...' : 'Serahkan Tugas',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5A623),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
