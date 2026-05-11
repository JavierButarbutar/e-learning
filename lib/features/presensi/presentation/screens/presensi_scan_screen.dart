import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../provider/presensi_provider.dart';
import '../widgets/control_button.dart';
import '../widgets/scanner_overlay.dart';
import 'konfirmasi_kehadiran_screen.dart';
import '../../data/models/presensi_model.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen>
    with SingleTickerProviderStateMixin {
  bool _flashOn = false;
  bool _scanning = false;
  bool _cameraPermissionGranted = false;

  // guard supaya scanner tidak detect berkali-kali
  bool _handled = false;

  late final MobileScannerController _cameraController;
  late AnimationController _scanAnim;
  late Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();

    // ── FIX: tambahkan detectionSpeed noDuplicates ──
    _cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLine = Tween<double>(begin: 0, end: 1).animate(_scanAnim);

    _requestCameraPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    await context.read<PresensiProvider>()
        .fetchActivePresensi();

    debugPrint(
      'ACTIVE PRESENSI: ${context.read<PresensiProvider>().presensiAktif.length}',
    );
  });
  }

  @override
  void dispose() {
    _scanAnim.dispose();

    try {
      _cameraController.dispose();
    } catch (_) {}

    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    if (_cameraPermissionGranted) return;

    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
      });
    } else if (status.isDenied) {
      _showSnackBar('Izin kamera diperlukan untuk scan QR');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // ─────────────────────────────────────────────
  // FIX BESAR:
  // - jangan await stop()
  // - kasih delay kecil
  // - hindari multi detect
  // ─────────────────────────────────────────────
  Future<void> _onDetect(String qrCode) async {
  if (_scanning || _handled) return;

  _handled = true;

  setState(() {
    _scanning = true;
  });

  try {
    debugPrint('QR DETECTED: $qrCode');

    if (!mounted) return;

    final provider = context.read<PresensiProvider>();

    debugPrint(
      'JUMLAH PRESENSI: ${provider.presensiAktif.length}',
    );
    provider.resetScan();

    // ==============================
    // VALIDASI QR PRESENSI
    // ==============================

    PresensiAktifModel? matchedPresensi;

    for (final item in provider.presensiAktif) {
      final qrDb =
          item.qrCode
              ?.toString()
              .trim()
              .toLowerCase() ?? '';

      final scanned =
          qrCode
              .toString()
              .trim()
              .toLowerCase();

      debugPrint('QR DB = [$qrDb]');
      debugPrint('QR SCAN = [$scanned]');

      if (qrDb == scanned) {
        matchedPresensi = item;
        break;
      }
    }

    // kalau tidak ditemukan
    if (matchedPresensi == null) {
      setState(() {
        _scanning = false;
      });

      _handled = false;

      _showSnackBar(
        'QR tidak valid untuk presensi',
        bg: Colors.red,
      );

      return;
    }

    // simpan presensi sesuai QR
    provider.setSelectedPresensi(
      matchedPresensi,
    );

    final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(
    builder: (_) => KonfirmasiKehadiranScreen(
      qrCode: qrCode,
    ),
  ),
);

if (result == true) {
  await provider.fetchActivePresensi();

  if (!mounted) return;

  Navigator.pop(context, true);
  return;
}

    if (!mounted) return;

    setState(() {
      _scanning = false;
      _handled = false;
    });

    if (result != true) {
      try {
        await _cameraController.start();
      } catch (e) {
        debugPrint('START CAMERA ERROR: $e');
      }
    }
  } catch (e, s) {
    debugPrint('SCAN ERROR: $e');
    debugPrintStack(stackTrace: s);

    if (!mounted) return;

    setState(() {
      _scanning = false;
      _handled = false;
    });

    _showSnackBar(
      'Error: ${e.toString()}',
      bg: Colors.red,
    );
  }
}

  void _showSnackBar(
    String msg, {
    Color bg = const Color(0xFF323232),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: bg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.62;
    final frameCenterY = size.height * 0.42;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─────────────────────────────────────
          // CAMERA
          // ─────────────────────────────────────
          if (_cameraPermissionGranted)
            Positioned.fill(
              child: MobileScanner(
                    controller: _cameraController,
                    fit: BoxFit.cover,
                    onDetect: (capture) async {
                      if (_handled) return;

                      final List<Barcode> barcodes = capture.barcodes;

                      if (barcodes.isEmpty) return;

                      final String? code = barcodes.first.rawValue;

                      if (code == null || code.isEmpty) return;

                      await _onDetect(code);
                    },
                  ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Meminta izin kamera...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─────────────────────────────────────
          // OVERLAY
          // ─────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: OverlayPainter(
                frameSize: frameSize,
                centerY: frameCenterY,
              ),
            ),
          ),

          // ─────────────────────────────────────
          // APPBAR
          // ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 12,
                16,
                16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
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
                    'Scan Presensi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────────────
          // FRAME QR
          // ─────────────────────────────────────
          Positioned(
            top: frameCenterY - frameSize / 2,
            left: (size.width - frameSize) / 2,
            width: frameSize,
            height: frameSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: FramePainter(
                      len: 22,
                      radius: 6,
                      framePaint: Paint()
                        ..color = Colors.white
                        ..strokeWidth = 3
                        ..style = PaintingStyle.stroke
                        ..strokeCap = StrokeCap.round,
                    ),
                  ),
                ),

                // scan line
                AnimatedBuilder(
                  animation: _scanLine,
                  builder: (_, __) => Positioned(
                    top: _scanLine.value * (frameSize - 4),
                    left: 8,
                    right: 8,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF2E7D32),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),

                // loading indicator
                if (_scanning)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      strokeWidth: 2.5,
                    ),
                  ),
              ],
            ),
          ),

          // ─────────────────────────────────────
          // TEXT
          // ─────────────────────────────────────
          Positioned(
            bottom: size.height * 0.30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Arahkan ke QR Code Presensi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan QR Code yang ditampilkan oleh guru\nuntuk mencatat kehadiran Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.55),
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ─────────────────────────────────────
          // BOTTOM BUTTONS
          // ─────────────────────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ControlButton(
                  icon: _flashOn
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  label: 'Flash',
                  active: _flashOn,
                  onTap: () async {
                    setState(() {
                      _flashOn = !_flashOn;
                    });

                    await _cameraController.toggleTorch();
                  },
                ),

                const SizedBox(width: 48),

                ControlButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Upload QR',
                  onTap: () {
                    _showSnackBar(
                      'Fitur upload QR dari galeri segera hadir',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}