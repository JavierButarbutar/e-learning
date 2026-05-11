import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../data/models/presensi_model.dart';
import '../../provider/presensi_provider.dart';
import '../widgets/info_tile.dart';
import '../widgets/success_dialog.dart';

// ─────────────────────────────────────────────────────────────
// KONFIRMASI KEHADIRAN SCREEN (NEW UI)
//
// UI baru tapi tetap terhubung API asli:
// ✔ ambil GPS
// ✔ submit scan QR ke backend Laravel
// ✔ support status hadir / terlambat
// ✔ support error 403 / 404 / 409 / 422
// ✔ dialog sukses sesuai status
// ─────────────────────────────────────────────────────────────

class KonfirmasiKehadiranScreen extends StatefulWidget {
  final String qrCode;

  const KonfirmasiKehadiranScreen({
    super.key,
    required this.qrCode,
  });

  @override
  State<KonfirmasiKehadiranScreen> createState() =>
      _KonfirmasiKehadiranScreenState();
}

class _KonfirmasiKehadiranScreenState
    extends State<KonfirmasiKehadiranScreen> {
  String? _latitude;
  String? _longitude;

  bool _gpsLoading = true;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  // ───────────────────────────────────────────────────────────
  // AMBIL GPS
  // ───────────────────────────────────────────────────────────
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _gpsError = 'GPS tidak aktif';
          _gpsLoading = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsError = 'Izin lokasi ditolak';
          _gpsLoading = false;
        });
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _gpsLoading = false;
      });
    } catch (e) {
      setState(() {
        _gpsError = e.toString();
        _gpsLoading = false;
      });
    }
  }

  // ───────────────────────────────────────────────────────────
  // SUBMIT SCAN
  // ───────────────────────────────────────────────────────────
  Future<void> _checkIn() async {
    final provider =
        context.read<PresensiProvider>();

    await provider.submitScan(
      qrCode: widget.qrCode,
      latitude: _latitude,
      longitude: _longitude,
    );

    if (!mounted) return;

    if (provider.scanStatus ==
            PresensiStatus.success &&
        provider.scanResult != null) {
      _showSuccessDialog(provider.scanResult!);
    }
  }

  // ───────────────────────────────────────────────────────────
  // DIALOG SUKSES
  // ───────────────────────────────────────────────────────────
  void _showSuccessDialog(
    ScanResultModel result,
  ) {
    final isTerlambat =
        result.statusKehadiran == 'terlambat';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(
        title: isTerlambat
            ? 'Presensi Terlambat'
            : 'Presensi Berhasil',
        subtitle: isTerlambat
            ? 'Kehadiran tercatat sebagai terlambat'
            : 'Kehadiran berhasil dicatat',
        isTerlambat: isTerlambat,
        mapel: result.mapel,
        kelas: result.kelas,
        waktu: result.waktuPresensi,
        jarak: result.jarakMeter,
        onBack: () async {
            Navigator.pop(context);

            final provider =
                context.read<PresensiProvider>();

            // refresh semua data
            await provider.fetchActivePresensi();
            await provider.fetchRiwayat();
            await provider.fetchRekap();

            Navigator.pop(context, true);
          },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<PresensiProvider>(
        builder: (context, provider, _) {
          final loading =
              provider.isLoadingScan || _gpsLoading;

          final presensi = provider.selectedPresensi;

          return Column(
            children: [
              // ─────────────────────────────────────────────
              // HEADER
              // ─────────────────────────────────────────────
              Container(
                color: const Color(0xFF2E7D32),
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context)
                          .padding
                          .top +
                      10,
                  16,
                  16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons
                              .arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Konfirmasi Kehadiran',
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

              // ─────────────────────────────────────────────
              // BODY
              // ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ICON
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE8F5E9),
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: const Icon(
                          Icons
                              .qr_code_scanner_rounded,
                          color:
                              Color(0xFF2E7D32),
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Konfirmasi Kehadiran',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'QR Code berhasil dipindai.\nSilakan periksa detail di bawah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ───────────────────────────────────
                      // CARD DETAIL
                      // ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2E7D32),
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'MATA PELAJARAN',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white
                                    .withOpacity(0.6),
                                letterSpacing: 0.8,
                                fontFamily:
                                    'Poppins',
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              presensi?.mapel ??
                                  '-',
                              style:
                                  const TextStyle(
                                fontSize: 26,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    Colors.white,
                                fontFamily:
                                    'Poppins',
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'KELAS',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white
                                    .withOpacity(0.6),
                                fontFamily:
                                    'Poppins',
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              presensi?.kelas ??
                                  '-',
                              style:
                                  const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    Color(
                                        0xFFF5A623),
                                fontFamily:
                                    'Poppins',
                              ),
                            ),

                            const SizedBox(
                                height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: InfoTile(
                                    icon: Icons
                                        .person_outline_rounded,
                                    label:
                                        'Nama Guru',
                                    value:
                                        presensi
                                                ?.guru ??
                                            '-',
                                    dark: true,
                                  ),
                                ),

                                const SizedBox(
                                    width: 10),

                                Expanded(
                                  child: InfoTile(
                                    icon: Icons
                                        .access_time_rounded,
                                    label:
                                        'Batas Waktu',
                                    value:
                                        presensi
                                                ?.jamSelesai ??
                                            '-',
                                    dark: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ───────────────────────────────────
                      // GPS STATUS
                      // ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _gpsError == null
                              ? const Color(
                                  0xFFE8F5E9)
                              : const Color(
                                  0xFFFFEBEE),
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _gpsError == null
                                  ? Icons
                                      .location_on_outlined
                                  : Icons
                                      .location_off_outlined,
                              color:
                                  _gpsError == null
                                      ? const Color(
                                          0xFF2E7D32)
                                      : const Color(
                                          0xFFE53935),
                            ),

                            const SizedBox(
                                width: 10),

                            Expanded(
                              child: Text(
                                loading
                                    ? 'Mengambil lokasi GPS...'
                                    : _gpsError ??
                                        'Lokasi berhasil didapatkan',
                                style:
                                    TextStyle(
                                  fontSize: 12,
                                  color: _gpsError ==
                                          null
                                      ? const Color(
                                          0xFF2E7D32)
                                      : const Color(
                                          0xFFE53935),
                                  fontFamily:
                                      'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ───────────────────────────────────
                      // ERROR API
                      // ───────────────────────────────────
                      if (provider.scanStatus ==
                              PresensiStatus
                                  .error &&
                          provider.scanError !=
                              null) ...[
                        const SizedBox(
                            height: 14),
                        _ErrorBanner(
                          message:
                              provider.scanError!,
                          isSudahAbsen:
                              provider.sudahAbsen,
                        ),
                      ],

                      const SizedBox(height: 14),

                      // ───────────────────────────────────
                      // INFO
                      // ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFF8E1),
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                          border: Border.all(
                            color:
                                const Color(
                                    0xFFFFE082),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons
                                  .info_outline_rounded,
                              color:
                                  Color(0xFFF5A623),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pastikan berada di dalam radius lokasi kelas sebelum check-in.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Color(
                                          0xFF856404),
                                  fontFamily:
                                      'Poppins',
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ───────────────────────────────────
                      // BUTTON
                      // ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              (loading ||
                                      _gpsError !=
                                          null)
                                  ? null
                                  : _checkIn,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors
                                        .white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .check_circle_outline_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            loading
                                ? 'Memproses...'
                                : 'Check-in Sekarang',
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                              fontFamily:
                                  'Poppins',
                            ),
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                                    0xFFF5A623),
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () =>
                            Navigator.pop(
                                context),
                        child: const Text(
                          'Bukan Kelas Saya? Batalkan',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Color(0xFF888888),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ERROR BANNER
// ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isSudahAbsen;

  const _ErrorBanner({
    required this.message,
    required this.isSudahAbsen,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSudahAbsen
        ? const Color(0xFF1E88E5)
        : const Color(0xFFE53935);

    final bgColor = isSudahAbsen
        ? const Color(0xFFE3F2FD)
        : const Color(0xFFFFEBEE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isSudahAbsen
                ? Icons.info_outline_rounded
                : Icons.error_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}