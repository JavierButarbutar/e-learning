import 'package:flutter/material.dart';

class PresensiScreen extends StatelessWidget {
  const PresensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 20),
          width: double.infinity,
          child: const Text('Presensi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white, fontFamily: 'Poppins')),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      size: 72, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 24),
                const Text('Scan QR untuk Presensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                const SizedBox(height: 10),
                const Text(
                  'Arahkan kamera ke QR Code\nyang ditampilkan oleh guru',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888),
                      fontFamily: 'Poppins', height: 1.6)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: const Text('Buka Kamera',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}