import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../kuis/presentation/screens/kuis_screen.dart';
import '../../../tugas/presentation/screens/upload_tugas_screen.dart';
import '../../data/models/mapel_model.dart';
import '../../data/models/progress_materi.dart';

class DetailMateriScreen extends StatefulWidget {
  final MateriItem item;
  final String namaMapel;

  const DetailMateriScreen({
    super.key,
    required this.item,
    required this.namaMapel,
  });

  @override
  State<DetailMateriScreen> createState() => _DetailMateriScreenState();
}

class _DetailMateriScreenState extends State<DetailMateriScreen> {
  bool _tugasDikumpulkan = false;
  bool _isCompleted      = false;

  final PdfViewerController _pdfController = PdfViewerController();
  int  _currentPage  = 1;
  int  _totalPages   = 1;
  bool _isLoadingPdf = true;

  // ── Key untuk SharedPreferences ──────────────────────────
  // Unik per materi agar tidak tabrakan antar materi
  String get _prefKey => 'materi_selesai_${widget.item.id}';

  // ── Apakah PDF sudah di halaman terakhir ─────────────────
  bool get _sudahHalamanTerakhir =>
      !_isLoadingPdf && (_totalPages <= 1 || _currentPage >= _totalPages);

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }
  // ── Load progress dari SharedPreferences ─────────────────
  // ✅ FIX 1: Progress disimpan persistent, tidak hilang setelah logout
  Future<void> _loadProgress() async {
    final prefs     = await SharedPreferences.getInstance();
    final selesai   = prefs.getBool(_prefKey) ?? false;

    // Sync ke ProgressStore (in-memory) juga
    final existing = ProgressStore.aktivitas
        .where((e) => e.materi == widget.item.judul);

    if (existing.isNotEmpty) {
      if (selesai) existing.first.isCompleted = true;
    } else {
      ProgressStore.aktivitas.add(
        ProgressMateri(
          mapel:       widget.namaMapel,
          materi:      widget.item.judul,
          item:        widget.item,
          isCompleted: selesai,
        ),
      );
    }

    if (mounted) setState(() => _isCompleted = selesai);
  }

  // ── Simpan progress ke SharedPreferences ─────────────────
  Future<void> _selesaikanMateri() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);

    final index = ProgressStore.aktivitas
        .indexWhere((e) => e.materi == widget.item.judul);
    if (index != -1) ProgressStore.aktivitas[index].isCompleted = true;

    if (!mounted) return;
    setState(() => _isCompleted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Materi berhasil diselesaikan'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  Future<void> _downloadPdf(String url, String fileName) async {
  try {

    await Permission.storage.request();

    final dir = Directory('/storage/emulated/0/Download');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = "${dir.path}/$fileName.pdf";

    await Dio().download(url, filePath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Download selesai: $fileName"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal download PDF: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final item     = widget.item;
    final hasTugas = item.type == MateriType.tugas;
    final hasKuis  = item.type == MateriType.kuis;

    // ✅ FIX 2: Tombol selesai SELALU tampil (tidak disembunyikan oleh tugas/kuis)
    // ✅ FIX 3: Tombol selesai hanya aktif setelah PDF di halaman terakhir
    final bolehSelesai = _sudahHalamanTerakhir && !_isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildAppBar(context),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (hasKuis) _KuisCard(item: item),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Text(
                      item.judul,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Poppins',
                        height: 1.3,
                      ),
                    ),
                  ),

                  if (item.namaFile != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          _fileIcon(item.tipeFile),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.namaFile!,
                              style: const TextStyle(fontSize: 12,
                                  color: Color(0xFF888888),
                                  fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.ukuranFile != null)
                            Text(item.ukuranFile!,
                                style: const TextStyle(fontSize: 11,
                                    color: Color(0xFFBBBBBB),
                                    fontFamily: 'Poppins')),
                        ],
                      ),
                    ),

                  _PdfViewer(
                    item: item,
                    controller: _pdfController,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    isLoading: _isLoadingPdf,
                    onDocumentLoaded: (details) {
                      setState(() {
                        _totalPages   = details.document.pages.count;
                        _isLoadingPdf = false;
                      });
                    },
                    onPageChanged: (details) {
                      setState(() => _currentPage = details.newPageNumber);
                    },
                    onDownload: () {
                      _downloadPdf(
                        item.fileUrl ?? '',
                        item.namaFile ?? 'materi',
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Tombol Selesai Dibaca ─────────────────
                  // ✅ Selalu tampil, tapi ada hint jika belum halaman terakhir
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Hint jika PDF belum selesai
                        if (!_isCompleted && !_sudahHalamanTerakhir && !_isLoadingPdf)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      size: 13, color: Color(0xFF888888)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Baca hingga halaman terakhir untuk menyelesaikan materi '
                                      '(Hal $_currentPage / $_totalPages)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF888888),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            // Aktif jika sudah halaman terakhir & belum selesai
                            onPressed: bolehSelesai ? _selesaikanMateri : null,
                            icon: Icon(_isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline_rounded,
                                size: 18),
                            label: Text(
                              _isCompleted
                                  ? 'Materi Sudah Selesai'
                                  : 'Selesai Dibaca',
                              style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCompleted
                                  ? const Color(0xFFEEEEEE)
                                  : const Color(0xFF2E7D32),
                              foregroundColor: _isCompleted
                                  ? const Color(0xFF888888)
                                  : Colors.white,
                              disabledBackgroundColor: const Color(0xFFEEEEEE),
                              disabledForegroundColor: const Color(0xFFBBBBBB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Card Tugas (jika ada) ─────────────────
                  if (hasTugas) ...[
                    const SizedBox(height: 12),
                    _TugasCard(
                      item: item,
                      sudahDikumpulkan: _tugasDikumpulkan,
                      namaMapel: widget.namaMapel,
                      onUpload: () => setState(() => _tugasDikumpulkan = true),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.namaMapel,
                style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins'),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _fileIcon(String? tipe) {
    IconData icon;
    Color    color;
    switch (tipe) {
      case 'word':
        icon = Icons.description_outlined;
        color = const Color(0xFF1E88E5);
        break;
      case 'ppt':
        icon = Icons.slideshow_outlined;
        color = const Color(0xFFE65100);
        break;
      default:
        icon = Icons.picture_as_pdf_outlined;
        color = const Color(0xFFE53935);
    }
    return Icon(icon, size: 16, color: color);
  }
}

// ─────────────────────────────────────────────────────────────
// PDF Viewer
// ─────────────────────────────────────────────────────────────
class _PdfViewer extends StatelessWidget {
  final MateriItem item;
  final PdfViewerController controller;
  final int  currentPage;
  final int  totalPages;
  final bool isLoading;
  final Function(PdfDocumentLoadedDetails) onDocumentLoaded;
  final Function(PdfPageChangedDetails)    onPageChanged;
  final VoidCallback? onDownload;

  const _PdfViewer({
    required this.item,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    required this.onDownload
  });

  @override
  Widget build(BuildContext context) {
    final pdfUrl = item.fileUrl ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Header PDF
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Row(children: [
                    Icon(Icons.picture_as_pdf_outlined,
                        size: 14, color: Color(0xFFE53935)),
                    SizedBox(width: 4),
                    Text('PDF', style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE53935), fontFamily: 'Poppins')),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.namaFile ?? 'Materi.pdf',
                      style: const TextStyle(fontSize: 12,
                          color: Color(0xFF555555), fontFamily: 'Poppins'),
                      overflow: TextOverflow.ellipsis),
                ),
                Text('Hal $currentPage / $totalPages',
                    style: const TextStyle(fontSize: 11,
                        color: Color(0xFF888888), fontFamily: 'Poppins')),
              ],
            ),
          ),

          // PDF content
          SizedBox(
            height: 600,
            child: Stack(children: [
              if (pdfUrl.isNotEmpty)
                SfPdfViewer.network(pdfUrl,
                    controller: controller,
                    onDocumentLoaded: onDocumentLoaded,
                    onPageChanged: onPageChanged)
              else
                const Center(
                  child: Text('PDF tidak tersedia',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                ),
              if (isLoading)
                Container(
                  color: Colors.white.withOpacity(0.8),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ]),
          ),

          // Footer navigasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () { if (currentPage > 1) controller.previousPage(); },
                  child: _NavBtn(
                    label: 'Sebelumnya',
                    icon: Icons.chevron_left_rounded,
                    iconLeft: true,
                    active: currentPage > 1,
                  ),
                ),
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded,
                  color: Color(0xFF2E7D32)),
                  tooltip: 'Download PDF',
                ),
                GestureDetector(
                  onTap: () {
                    if (currentPage < totalPages) controller.nextPage();
                  },
                  child: _NavBtn(
                    label: 'Selanjutnya',
                    icon: Icons.chevron_right_rounded,
                    iconLeft: false,
                    active: currentPage < totalPages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     iconLeft;
  final bool     active;

  const _NavBtn({
    required this.label,
    required this.icon,
    required this.iconLeft,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : const Color(0xFFBBBBBB);
    final bg    = active ? const Color(0xFF2E7D32) : const Color(0xFFEEEEEE);
    final iconW = Icon(icon, size: 18, color: color);
    final text  = Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            fontFamily: 'Poppins', color: color));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bg,
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: iconLeft
          ? [iconW, text]
          : [text, iconW]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kuis Card
// ─────────────────────────────────────────────────────────────
class _KuisCard extends StatelessWidget {
  final MateriItem item;
  const _KuisCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: const Color(0xFFFF8F00),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.quiz_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text('Kuis Evaluasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                  color: Color(0xFFE65100), fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tugas Card
// ─────────────────────────────────────────────────────────────
class _TugasCard extends StatelessWidget {
  final MateriItem   item;
  final bool         sudahDikumpulkan;
  final VoidCallback onUpload;
  final String       namaMapel;

  const _TugasCard({
    required this.item,
    required this.sudahDikumpulkan,
    required this.onUpload,
    required this.namaMapel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Tugas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
          ),
          const SizedBox(height: 12),
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
                // Info deadline tugas
                if (item.deadlineTugas != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: Color(0xFFE53935)),
                      const SizedBox(width: 5),
                      Text('Deadline: ${item.deadlineTugas}',
                          style: const TextStyle(fontSize: 12,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins')),
                    ]),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => UploadTugasScreen(
                          idTugas:        item.idTugas ?? '',
                          judulTugas:     item.judul,
                          deskripsiTugas: item.konten ?? '-',
                          deadline:       item.deadlineTugas ?? '-',
                          namaMapel:      namaMapel,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: Text(
                      sudahDikumpulkan ? 'Lihat Tugas' : 'Upload Tugas',
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudahDikumpulkan
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF5A623),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}