import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
// ─────────────────────────────────────────────────────────────
// SCAN QR CODE SCREEN
// ─────────────────────────────────────────────────────────────
class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});
  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen>
    with SingleTickerProviderStateMixin {
  bool _flashOn = false;
  bool _scanning = false;
  late AnimationController _scanAnim;
  late Animation<double> _scanLine;

Future<void> _requestCameraPermission() async {
  final status = await Permission.camera.request();

  if (status.isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Izin kamera diperlukan untuk scan QR'),
      ),
    );
  }

  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

  @override
void initState() {
  super.initState();

  _requestCameraPermission();

  _scanAnim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  _scanLine = Tween<double>(begin: 0, end: 1).animate(_scanAnim);
}

  @override
  void dispose() {
    _scanAnim.dispose();
    super.dispose();
  }

  void _simulateScan() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _scanning = false);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => const KonfirmasiKehadiranScreen()));
  }
  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.62;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Simulasi kamera
        Positioned.fill(
          child: MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.back,
              torchEnabled: _flashOn,
            ),
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final code = barcode.rawValue;

              if (code != null && !_scanning) {
                _simulateScan();
              }
            },
          ),
        ),

        // Overlay gelap di luar frame
        Positioned.fill(
          child: CustomPaint(
            painter: _OverlayPainter(
                frameSize: frameSize,
                centerY: size.height * 0.42),
          ),
        ),

        // AppBar
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Scan Presence',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
            ]),
          ),
        ),

        // Frame QR
        Positioned(
          top: size.height * 0.42 - frameSize / 2,
          left: (size.width - frameSize) / 2,
          width: frameSize,
          height: frameSize,
          child: GestureDetector(
            onTap: _simulateScan,
            child: Stack(children: [
              // Corner brackets
              ..._corners(frameSize),

              // Scan line animasi
              AnimatedBuilder(
                animation: _scanLine,
                builder: (_, __) => Positioned(
                  top: _scanLine.value * (frameSize - 4),
                  left: 8, right: 8,
                  height: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        const Color(0xFF2E7D32),
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
                      color: Color(0xFF2E7D32), strokeWidth: 2.5),
                ),
            ]),
          ),
        ),

        // Teks panduan
        Positioned(
          bottom: size.height * 0.30,
          left: 0, right: 0,
          child: Column(children: [
            const Text('Align QR Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Text('Position the QR code within the frame\nto verify attendance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,
                  color: Colors.white.withOpacity(0.55),
                  fontFamily: 'Poppins', height: 1.5)),
          ]),
        ),

        // Bottom controls
        Positioned(
          bottom: 48, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CtrlBtn(
                icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                label: 'Flash',
                active: _flashOn,
                onTap: () => setState(() => _flashOn = !_flashOn),
              ),
              const SizedBox(width: 48),
              _CtrlBtn(
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
      ]),
    );
  }

  List<Widget> _corners(double size) {
    const len = 22.0;
    const thick = 3.0;
    const r = 6.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    return [Positioned.fill(child: CustomPaint(
      painter: _FramePainter(len: len, radius: r, framePaint: p),
    ))];
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _CtrlBtn({required this.icon, required this.label,
      required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? const Color(0xFFF5A623)
              : Colors.white.withOpacity(0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 11,
          color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins')),
    ]),
  );
}

class _OverlayPainter extends CustomPainter {
  final double frameSize, centerY;
  _OverlayPainter({required this.frameSize, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black.withOpacity(0.65);
    final cx = size.width / 2;
    final cy = centerY;
    final h = frameSize / 2;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cy - h), p);
    canvas.drawRect(Rect.fromLTWH(0, cy + h, size.width, size.height), p);
    canvas.drawRect(Rect.fromLTWH(0, cy - h, cx - h, frameSize), p);
    canvas.drawRect(Rect.fromLTWH(cx + h, cy - h, size.width, frameSize), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FramePainter extends CustomPainter {
  final double len, radius;
  final Paint framePaint;

  _FramePainter({
    required this.len,
    required this.radius,
    required this.framePaint,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final corners = [
      [Offset(0, len), Offset(0, radius), Offset(radius, 0), Offset(len, 0)],
      [
        Offset(s.width - len, 0),
        Offset(s.width - radius, 0),
        Offset(s.width, radius),
        Offset(s.width, len)
      ],
      [
        Offset(s.width, s.height - len),
        Offset(s.width, s.height - radius),
        Offset(s.width - radius, s.height),
        Offset(s.width - len, s.height)
      ],
      [
        Offset(len, s.height),
        Offset(radius, s.height),
        Offset(0, s.height - radius),
        Offset(0, s.height - len)
      ],
    ];

    for (final c in corners) {
      canvas.drawLine(c[0], c[1], framePaint);
      canvas.drawLine(c[2], c[3], framePaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// KONFIRMASI KEHADIRAN
// ─────────────────────────────────────────────────────────────
class KonfirmasiKehadiranScreen extends StatefulWidget {
  const KonfirmasiKehadiranScreen({super.key});
  @override
  State<KonfirmasiKehadiranScreen> createState() =>
      _KonfirmasiKehadiranScreenState();
}

class _KonfirmasiKehadiranScreenState
    extends State<KonfirmasiKehadiranScreen> {
  bool _loading = false;

  void _checkIn() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _loading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        onBack: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // Header
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
            const Text('Konfirmasi Kehadiran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(height: 8),
              // Icon sukses scan
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    color: Color(0xFF2E7D32), size: 38),
              ),
              const SizedBox(height: 14),
              const Text('Konfirmasi Kehadiran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              const Text(
                'QR Code berhasil dipindai. Silakan periksa\ndetail di bawah.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF888888),
                    fontFamily: 'Poppins', height: 1.5)),
              const SizedBox(height: 20),

              // Card detail kelas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MATA PELAJARAN',
                      style: TextStyle(fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.8, fontFamily: 'Poppins')),
                    const SizedBox(height: 4),
                    const Text('Matematika',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: Colors.white, fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Text('Materi Pembelajaran',
                      style: TextStyle(fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Poppins')),
                    const SizedBox(height: 3),
                    const Text('Aljabar Linear',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: Color(0xFFF5A623), fontFamily: 'Poppins')),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _InfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Nama Guru',
                        value: 'Dr. Budi Santoso',
                        dark: true,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _InfoTile(
                        icon: Icons.access_time_rounded,
                        label: 'Batas Waktu',
                        value: '09:00 WIB',
                        dark: true,
                      )),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Info radius
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFF5A623), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastikan Anda berada di dalam radius lokasi kelas sebelum menekan tombol check-in.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF856404),
                          fontFamily: 'Poppins', height: 1.5)),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // Tombol check-in
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _checkIn,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                  label: Text(_loading ? 'Memproses...' : 'Check-in Sekarang',
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bukan Kelas Saya? Batalkan',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888),
                      fontFamily: 'Poppins')),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool dark;
  const _InfoTile({required this.icon, required this.label,
      required this.value, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.12) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13,
              color: dark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF888888)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10,
              color: dark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF888888),
              fontFamily: 'Poppins')),
        ]),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: dark ? Colors.white : const Color(0xFF1A1A1A),
            fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onBack;
  const _SuccessDialog({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFE8F5E9)),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF2E7D32), size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Kehadiran Berhasil!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                fontFamily: 'Poppins', color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text('Kamu telah tercatat hadir\ndi kelas Matematika.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF888888),
                fontFamily: 'Poppins', height: 1.5)),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kembali ke Dashboard',
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}