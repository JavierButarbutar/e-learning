import 'package:flutter/material.dart';
import '../core/models/mapel_model.dart';

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
  int _currentPage = 1;
  bool _tugasDikumpulkan = false;

  int get _totalPages => widget.item.jumlahHalaman ?? 1;

  void _prevPage() {
    if (_currentPage > 1) setState(() => _currentPage--);
  }

  void _nextPage() {
    if (_currentPage < _totalPages) setState(() => _currentPage++);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasTugas = item.type == MateriType.tugas;
    final hasKuis  = item.type == MateriType.kuis;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── AppBar hijau ──
          _buildAppBar(context),

          // ── Konten scroll ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Card Kuis (muncul hanya jika ada kuis) ───
                  if (hasKuis) _KuisCard(item: item),

                  // ─── Judul materi ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Text(item.judul,
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins',
                        height: 1.3,
                      )),
                  ),

                  // ─── Info file ───
                  if (item.namaFile != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(children: [
                        _fileIcon(item.tipeFile),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item.namaFile!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF888888),
                                fontFamily: 'Poppins'),
                            overflow: TextOverflow.ellipsis),
                        ),
                        if (item.ukuranFile != null)
                          Text(item.ukuranFile!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB),
                                fontFamily: 'Poppins')),
                      ]),
                    ),

                  // ─── PDF Viewer simulasi ───
                  _PdfViewer(
                    item: item,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPrev: _prevPage,
                    onNext: _nextPage,
                  ),

                  const SizedBox(height: 16),

                  // ─── Card Tugas (muncul hanya jika ada tugas) ───
                  if (hasTugas)
                    _TugasCard(
                      item: item,
                      sudahDikumpulkan: _tugasDikumpulkan,
                      onUpload: () => setState(() => _tugasDikumpulkan = true),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 14),
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
        Expanded(
          child: Text(widget.namaMapel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins'),
            overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  Widget _fileIcon(String? tipe) {
    IconData icon;
    Color color;
    switch (tipe) {
      case 'word': icon = Icons.description_outlined; color = const Color(0xFF1E88E5); break;
      case 'ppt':  icon = Icons.slideshow_outlined;   color = const Color(0xFFE65100); break;
      default:     icon = Icons.picture_as_pdf_outlined; color = const Color(0xFFE53935); break;
    }
    return Icon(icon, size: 16, color: color);
  }
}

// ═══════════════════════════════════════════════════════════════
// PDF Viewer Simulasi
// Di production: ganti dengan flutter_pdfview atau syncfusion_flutter_pdfviewer
// ═══════════════════════════════════════════════════════════════
class _PdfViewer extends StatelessWidget {
  final MateriItem item;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PdfViewer({
    required this.item,
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar PDF ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(children: const [
                  Icon(Icons.picture_as_pdf_outlined,
                      size: 14, color: Color(0xFFE53935)),
                  SizedBox(width: 4),
                  Text('PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: Color(0xFFE53935), fontFamily: 'Poppins')),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.namaFile ?? 'Materi.pdf',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555),
                      fontFamily: 'Poppins'),
                  overflow: TextOverflow.ellipsis),
              ),
              Text('Hal $currentPage dari $totalPages',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
            ]),
          ),

          // ── Isi halaman PDF (simulasi) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul dalam "halaman"
                Text(item.judul,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text('Halaman $currentPage dari $totalPages',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
                      fontFamily: 'Poppins')),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                const SizedBox(height: 14),

                // Konten teks dummy simulasi isi PDF
                Text(
                  _pageContent(currentPage),
                  style: const TextStyle(
                    fontSize: 13, color: Color(0xFF333333),
                    fontFamily: 'Poppins', height: 1.8,
                  ),
                ),

                // Simulasi diagram/gambar di halaman tertentu
                if (currentPage == 2 || currentPage == 4)
                  _FakeDiagram(),
              ],
            ),
          ),

          // ── Navigasi halaman ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Prev
                GestureDetector(
                  onTap: onPrev,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: currentPage > 1
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Icon(Icons.chevron_left_rounded,
                          size: 18,
                          color: currentPage > 1 ? Colors.white : const Color(0xFFBBBBBB)),
                      Text('Sebelumnya',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: currentPage > 1 ? Colors.white : const Color(0xFFBBBBBB))),
                    ]),
                  ),
                ),

                // Progress dots
                Row(
                  children: List.generate(
                    totalPages > 5 ? 5 : totalPages,
                    (i) {
                      final pageIdx = totalPages > 5
                          ? (currentPage - 1).clamp(0, totalPages - 5) + i
                          : i;
                      final isActive = pageIdx == currentPage - 1;
                      return Container(
                        width: isActive ? 16 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFDDDDDD),
                        ),
                      );
                    },
                  ),
                ),

                // Next
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: currentPage < totalPages
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Text('Selanjutnya',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: currentPage < totalPages ? Colors.white : const Color(0xFFBBBBBB))),
                      Icon(Icons.chevron_right_rounded,
                          size: 18,
                          color: currentPage < totalPages ? Colors.white : const Color(0xFFBBBBBB)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pageContent(int page) {
    // Simulasi konten tiap halaman berbeda
    final lines = (item.konten ?? '').split('\n\n');
    final idx = (page - 1) % lines.length;
    final content = lines[idx].trim();
    return content.isEmpty ? lines[0] : content;
  }
}

// Simulasi diagram/gambar dalam PDF
class _FakeDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(children: [
        // Fake diagram boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _diagBox('Input'),
            _diagArrow(),
            _diagBox('Proses'),
            _diagArrow(),
            _diagBox('Output'),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar simulasi
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.85,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('85%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
        ]),
        const SizedBox(height: 6),
        Text('Gambar 1. Diagram Alur Sistem',
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888),
              fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _diagBox(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF2E7D32)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
  );

  Widget _diagArrow() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF2E7D32)),
  );
}

// ═══════════════════════════════════════════════════════════════
// Card Kuis — muncul HANYA jika materi punya kuis
// ═══════════════════════════════════════════════════════════════
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.quiz_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Kuis Evaluasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                  color: Color(0xFFE65100), fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFF57C00)),
              const SizedBox(width: 3),
              Text('${item.durasiMenit ?? 15} menit',
                style: const TextStyle(fontSize: 11, color: Color(0xFFF57C00),
                    fontFamily: 'Poppins')),
              const SizedBox(width: 10),
              const Icon(Icons.help_outline_rounded, size: 13, color: Color(0xFFF57C00)),
              const SizedBox(width: 3),
              Text('${item.jumlahSoal ?? 10} Soal',
                style: const TextStyle(fontSize: 11, color: Color(0xFFF57C00),
                    fontFamily: 'Poppins')),
            ]),
          ]),
        ),
        GestureDetector(
          onTap: () => _showKuisDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Mulai Kuis',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
          ),
        ),
      ]),
    );
  }

  void _showKuisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mulai Kuis?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
        content: Text(
          'Kuis ini terdiri dari ${item.jumlahSoal ?? 10} soal dengan durasi ${item.durasiMenit ?? 15} menit. Pastikan kamu sudah membaca materi sebelum memulai.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
              style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mulai',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Card Tugas — muncul HANYA jika materi punya tugas
// ═══════════════════════════════════════════════════════════════
class _TugasCard extends StatelessWidget {
  final MateriItem item;
  final bool sudahDikumpulkan;
  final VoidCallback onUpload;

  const _TugasCard({
    required this.item,
    required this.sudahDikumpulkan,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label "Tugas"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Tugas',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
          ),

          const SizedBox(height: 12),

          // Header Daftar Tugas
          const Text('Daftar Tugas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),

          const SizedBox(height: 12),

          // Card tugas upload
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_outlined,
                        color: Color(0xFFF5A623), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tugas Makalah',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                      const SizedBox(height: 2),
                      const Text('Upload file PDF/Word',
                        style: TextStyle(fontSize: 11, color: Color(0xFF888888),
                            fontFamily: 'Poppins')),
                    ]),
                  ),
                ]),

                // Deadline
                if (item.deadlineTugas != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: Color(0xFFE53935)),
                      const SizedBox(width: 5),
                      Text('Deadline: ${item.deadlineTugas}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: Color(0xFFE53935), fontFamily: 'Poppins')),
                    ]),
                  ),
                ],

                const SizedBox(height: 14),

                // Status / Tombol upload
                if (sudahDikumpulkan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2E7D32)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32), size: 18),
                        SizedBox(width: 6),
                        Text('Tugas Sudah Dikumpulkan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32), fontFamily: 'Poppins')),
                      ],
                    ),
                  )
                else
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.attach_file_rounded, size: 18),
                        label: const Text('Pilih File',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                              fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onUpload,
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text('Upload',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                              fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5A623),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}