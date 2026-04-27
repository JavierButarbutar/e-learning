// lib/guru/core/notifikasi_service.dart
//
// Service notifikasi pengingat jadwal mengajar.
// Gunakan package: flutter_local_notifications + timezone
//
// Setup pubspec.yaml:
//   flutter_local_notifications: ^17.0.0
//   timezone: ^0.9.4
//
// Panggil NotifikasiService.init() di main() sebelum runApp()
// Panggil NotifikasiService.jadwalkanSemuaHari() setelah login guru

import 'package:flutter/material.dart';

/// Placeholder service — implementasi penuh ada di bawah komentar.
/// Ganti dengan flutter_local_notifications saat integrasi nyata.
class NotifikasiService {
  NotifikasiService._();

  /// Inisialisasi plugin notifikasi.
  /// Panggil di main() sebelum runApp().
  static Future<void> init() async {
    // TODO: Implementasi nyata:
    //
    // final plugin = FlutterLocalNotificationsPlugin();
    // const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const ios    = DarwinInitializationSettings(requestAlertPermission: true);
    // await plugin.initialize(
    //   const InitializationSettings(android: android, iOS: ios));
    // await tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    debugPrint('[NotifikasiService] Initialized');
  }

  /// Jadwalkan notifikasi 10 menit sebelum setiap sesi mengajar hari ini.
  /// Panggil setiap kali app dibuka / login.
  static Future<void> jadwalkanHariIni(List<_JadwalSimple> jadwalHariIni) async {
    // TODO: Implementasi nyata:
    //
    // final plugin = FlutterLocalNotificationsPlugin();
    // await plugin.cancelAll(); // hapus jadwal lama
    //
    // for (final jadwal in jadwalHariIni) {
    //   final waktuNotif = jadwal.jamMulai.subtract(const Duration(minutes: 10));
    //   if (waktuNotif.isBefore(DateTime.now())) continue; // sudah lewat
    //
    //   await plugin.zonedSchedule(
    //     jadwal.id,
    //     '🔔 Jadwal Mengajar 10 Menit Lagi',
    //     '${jadwal.namaKelas} - ${jadwal.mataPelajaran} di ${jadwal.ruangan}',
    //     tz.TZDateTime.from(waktuNotif, tz.local),
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'jadwal_channel', 'Jadwal Mengajar',
    //         channelDescription: 'Pengingat jadwal mengajar guru',
    //         importance: Importance.high,
    //         priority: Priority.high,
    //         icon: '@mipmap/ic_launcher',
    //       ),
    //       iOS: DarwinNotificationDetails(
    //         presentAlert: true, presentBadge: true, presentSound: true),
    //     ),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.absoluteTime,
    //   );
    //   debugPrint('[Notif] Scheduled: ${jadwal.namaKelas} at $waktuNotif');
    // }

    debugPrint('[NotifikasiService] Scheduled ${jadwalHariIni.length} notifications');
  }

  /// Batalkan semua notifikasi yang terjadwal.
  static Future<void> batalkanSemua() async {
    // await FlutterLocalNotificationsPlugin().cancelAll();
    debugPrint('[NotifikasiService] All cancelled');
  }
}

/// Data minimal yang dibutuhkan untuk jadwalkan notifikasi
class _JadwalSimple {
  final int id;
  final String namaKelas;
  final String mataPelajaran;
  final String ruangan;
  final DateTime jamMulai;

  const _JadwalSimple({
    required this.id,
    required this.namaKelas,
    required this.mataPelajaran,
    required this.ruangan,
    required this.jamMulai,
  });
}