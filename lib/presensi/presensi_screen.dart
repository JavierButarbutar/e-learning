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
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 20),
          width: double.infinity,
          child: const Text('Presensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
        ),
        Expanded(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.qr_code_scanner_rounded, size: 60, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 20),
              const Text('Scan QR untuk Presensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              const Text('Arahkan kamera ke QR Code\nyang ditampilkan guru', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF888888), fontFamily: 'Poppins', height: 1.5)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Buka Kamera', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}