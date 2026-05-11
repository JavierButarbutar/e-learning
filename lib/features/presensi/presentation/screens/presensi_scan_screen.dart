import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/control_button.dart';
import '../widgets/scanner_overlay.dart';
import 'konfirmasi_kehadiran_screen.dart';

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

  late final MobileScannerController _cameraController;
  late AnimationController _scanAnim;
  late Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();

    _cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLine = Tween<double>(begin: 0, end: 1).animate(_scanAnim);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scanAnim.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    if (_cameraPermissionGranted) return;

    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() => _cameraPermissionGranted = true);
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin kamera diperlukan untuk scan QR'),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _simulateScan() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _scanning = false);

    await _cameraController.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KonfirmasiKehadiranScreen(),
      ),
    ).then((_) {
      if (mounted) _cameraController.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.62;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Kamera / Placeholder ─────────────────────────────
          if (_cameraPermissionGranted)
            Positioned.fill(
              child: MobileScanner(
                controller: _cameraController,
                onDetect: (capture) {
                  final code = capture.barcodes.first.rawValue;
                  if (code != null && !_scanning) _simulateScan();
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
                      Icon(Icons.camera_alt_outlined,
                          color: Colors.white54, size: 48),
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

          // ── Overlay gelap di luar frame ──────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: OverlayPainter(
                frameSize: frameSize,
                centerY: size.height * 0.42,
              ),
            ),
          ),

          // ── AppBar custom ────────────────────────────────────
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
                    'Scan Presence',
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

          // ── Frame QR dengan scan line ────────────────────────
          Positioned(
            top: size.height * 0.42 - frameSize / 2,
            left: (size.width - frameSize) / 2,
            width: frameSize,
            height: frameSize,
            child: GestureDetector(
              onTap: _simulateScan,
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

                  // Scan line animasi
                  AnimatedBuilder(
                    animation: _scanLine,
                    builder: (_, __) => Positioned(
                      top: _scanLine.value * (frameSize - 4),
                      left: 8,
                      right: 8,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Colors.transparent,
                            Color(0xFF2E7D32),
                            Colors.transparent,
                          ]),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),

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
          ),

          // ── Teks panduan ─────────────────────────────────────
          Positioned(
            bottom: size.height * 0.30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Align QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Position the QR code within the frame\nto verify attendance',
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

          // ── Bottom controls ──────────────────────────────────
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
                  onTap: () {
                    setState(() => _flashOn = !_flashOn);
                    _cameraController.toggleTorch();
                  },
                ),
                const SizedBox(width: 48),
                ControlButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Upload QR',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upload QR dari galeri'),
                      backgroundColor: Color(0xFF2E7D32),
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