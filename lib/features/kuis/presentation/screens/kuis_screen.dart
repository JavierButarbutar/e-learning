import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/kuis_provider.dart';
import '../widgets/kuis_header.dart';
import '../widgets/soal_card.dart';
import '../widgets/pilihan_ganda_widget.dart';
import '../widgets/esai_widget.dart';
import '../widgets/navigasi_soal.dart';
import '../widgets/kuis_bottom_nav.dart';
import '../../data/models/soal_model.dart';

class KuisScreen extends StatefulWidget {
  final int kuisId;
  const KuisScreen({super.key, required this.kuisId});

  @override
  State<KuisScreen> createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> with WidgetsBindingObserver {
  bool _dialogSudahTampil = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KuisProvider>().initKuis(kuisId: widget.kuisId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;
    final kuis = context.read<KuisProvider>();

    if (state == AppLifecycleState.paused) {
      await kuis.onAppBackground();
    }

    if (state == AppLifecycleState.resumed && mounted) {
      if (kuis.selesai && !_dialogSudahTampil) {
        _dialogSudahTampil = true;

        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return context.read<KuisProvider>().isSubmitting;
        });

        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Kuis Dikumpulkan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Kuis telah otomatis dikumpulkan karena kamu keluar sebanyak 3 kali.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (mounted) Navigator.pop(context, true);
        }
      } else if (kuis.tampilkanPeringatan) {
        _showExitWarningDialog(kuis.jumlahKeluar);
      }
    }
  }

  Future<void> _submitDanKembali() async {
    await context.read<KuisProvider>().submitKuis();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _showExitWarningDialog(int jumlahKeluar) {
    final kuis = context.read<KuisProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF5A623),
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Peringatan!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kamu sudah keluar dari kuis sebanyak $jumlahKeluar kali.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE53935),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jika keluar ${kuis.sisaKesempatan} kali lagi, '
                      'kuis akan otomatis dikumpulkan.',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFE53935),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Lanjutkan Kuis',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    final kuis = context.read<KuisProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Kuis?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
        ),
        content: Text(
          kuis.jumlahKeluar >= 2
              ? 'Ini adalah kesempatan terakhirmu. Keluar sekarang akan '
                    'mengumpulkan kuis secara otomatis!'
              : 'Jawaban yang sudah diisi tidak akan hilang, '
                    'tapi batas keluar kamu akan berkurang.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Lanjut Kuis',
              style: TextStyle(color: Color(0xFF2E7D32), fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelesai() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Kumpulkan Kuis?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
        ),
        content: Consumer<KuisProvider>(
          builder: (_, kuis, __) => Text(
            'Kamu sudah menjawab ${kuis.jumlahTerjawab} dari '
            '${kuis.soalList.length} soal. Yakin ingin mengumpulkan?',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Belum',
              style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Kumpulkan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;
    await _submitDanKembali(); // ✅ FIX — tidak lagi _showResultDialog
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KuisProvider>(
      builder: (context, kuis, _) {
        if (kuis.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (kuis.errorMessage != null && kuis.soalList.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFE53935),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      kuis.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final soal = kuis.soalSekarang;
        if (soal == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              KuisHeader(onBack: _showExitDialog),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SoalCard(soal: soal),
                      const SizedBox(height: 14),
                      if (soal.tipe == TipeSoal.pilihanGanda)
                        PilihanGandaWidget(soal: soal)
                      else
                        EsaiWidget(soal: soal),
                      const SizedBox(height: 20),
                      const NavigasiSoal(),
                    ],
                  ),
                ),
              ),
              KuisBottomNav(onSelesai: _handleSelesai),
            ],
          ),
        );
      },
    );
  }
}
