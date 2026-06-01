import 'package:flutter/material.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../data/repositories/kuis_repository.dart';
import '../../data/models/kuis_model.dart';
import '../../data/models/soal_model.dart';
import 'kuis_screen.dart';

class KuisDetailScreen extends StatefulWidget {
  final int kuisId;
  const KuisDetailScreen({super.key, required this.kuisId});

  @override
  State<KuisDetailScreen> createState() => _KuisDetailScreenState();
}

class _KuisDetailScreenState extends State<KuisDetailScreen> {
  KuisModel? _kuis;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await SharedPref.getToken() ?? '';
      final kuis = await KuisRepository.getDetailKuis(
        token: token,
        kuisId: widget.kuisId,
      );
      if (!mounted) return;

      if (kuis == null) {
        setState(() {
          _error = 'Kuis tidak dapat dimuat. Pastikan koneksi internet stabil.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _kuis = kuis;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail kuis. Coba lagi.';
        _loading = false;
      });
    }
  }

  Future<void> _mulaiKuis() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => KuisScreen(kuisId: widget.kuisId)),
    );

    if (mounted) {
      await _loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    if (_error != null || _kuis == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Kuis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Kuis tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadDetail,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final kuis = _kuis!;

    final sudah = kuis.sudahDikerjakan ?? false;

    final status = kuis.statusPengerjaan ?? 'belum_mulai';
    final bisaResume = status == 'sedang_mengerjakan';
    final sudahSelesai = status == 'selesai' || status == 'menunggu';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(kuis),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(kuis),
                  const SizedBox(height: 14),
                  if (sudahSelesai) _buildStatusSudahDikerjakan(kuis),
                  if (bisaResume) _buildStatusResume(),
                  if (!sudahSelesai && !bisaResume)
                    _buildStatusBelumDikerjakan(),
                  const SizedBox(height: 14),
                  _buildAturanCard(kuis),
                ],
              ),
            ),
          ),
          _buildBottomButton(sudahSelesai, bisaResume),
        ],
      ),
    );
  }

  Widget _buildHeader(KuisModel kuis) {
    return Container(
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
          Expanded(
            child: Text(
              kuis.judulKuis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(KuisModel kuis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kuis.tipeKuis.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            kuis.judulKuis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${kuis.namaMapel} · ${kuis.namaKelas}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time_rounded,
                '${kuis.durasiMenit} menit',
              ),
              const SizedBox(width: 10),

              _buildInfoChip(
                Icons.quiz_outlined,
                (kuis.jumlahSoal != null && kuis.jumlahSoal! > 0)
                    ? '${kuis.jumlahSoal} soal'
                    : 'Lihat soal',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF888888)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBelumDikerjakan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.pending_outlined, color: Color(0xFF888888), size: 22),
          SizedBox(width: 10),
          Text(
            'Kuis belum dikerjakan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusResume() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: Color(0xFFF5A623), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kuis sedang dikerjakan. Lanjutkan sebelum waktu habis.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF856404),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSudahDikerjakan(KuisModel kuis) {
    final tampilNilai = kuis.tampilkanNilai && kuis.nilaiAkhir != null;
    final menunggu = kuis.statusPengerjaan == 'menunggu';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2E7D32),
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kuis Sudah Dikerjakan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),

          if (tampilNilai) ...[
            Text(
              kuis.nilaiAkhir!.toStringAsFixed(0),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E7D32),
              ),
            ),
            const Text(
              'Nilai Kamu',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],

          if (!tampilNilai && !menunggu)
            const Text(
              'Nilai akan ditampilkan oleh guru',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),

          if (menunggu) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFFF5A623),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Soal esai sedang menunggu penilaian guru.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFF5A623),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAturanCard(KuisModel kuis) {
    final aturan = [
      'Kuis berlangsung selama ${kuis.durasiMenit} menit.',
      'Keluar dari aplikasi sebanyak 3 kali akan mengumpulkan kuis secara otomatis.',
      'Jawaban yang sudah diisi tersimpan otomatis.',
      'Pastikan koneksi internet stabil sebelum memulai.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFF5A623),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Peraturan Kuis',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF856404),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...aturan.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key + 1}. ',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF856404),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool sudahSelesai, bool bisaResume) {
    final String label;
    final IconData icon;
    final Color bgColor;

    if (sudahSelesai) {
      label = 'Kuis Sudah Dikerjakan';
      icon = Icons.lock_outline_rounded;
      bgColor = const Color(0xFFBDBDBD);
    } else if (bisaResume) {
      label = 'Lanjutkan Kuis';
      icon = Icons.play_circle_outline_rounded;
      bgColor = const Color(0xFFF5A623);
    } else {
      label = 'Mulai Kuis Sekarang';
      icon = Icons.play_arrow_rounded;
      bgColor = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: sudahSelesai ? null : _mulaiKuis,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFBDBDBD),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
