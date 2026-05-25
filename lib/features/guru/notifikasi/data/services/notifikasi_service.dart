import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// =========================================
// BACKGROUND HANDLER (harus top-level)
// =========================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Sistem handle otomatis, tidak perlu show manual
  print("NOTIF BACKGROUND : ${message.notification?.title}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId   = 'elearning_channel';
  static const _channelName = 'E-Learning Notifikasi';

  // =========================================
  // INIT
  // =========================================
  static Future<void> initialize() async {
    // Android & iOS init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Buat channel Android (WAJIB agar notif foreground muncul)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Notifikasi jadwal mengajar guru',
            importance: Importance.high,
          ),
        );

    // Permission iOS + Android 13+
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Daftarkan background handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Foreground → tampilkan via local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("NOTIF FOREGROUND : ${message.notification?.title}");
      showNotification(message);
    });

    // Notif diklik saat app background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIF DIKLIK BACKGROUND : ${message.data}");
    });

    // App dibuka dari notif (terminated)
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("APP DIBUKA DARI NOTIF : ${initialMessage.data}");
    }
  }

  // =========================================
  // SHOW LOCAL NOTIFICATION
  // =========================================
  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,   // ← sama dengan channel_id di backend FcmService.php
      _channelName,
      importance:        Importance.max,
      priority:          Priority.high,
      playSound:         true,
      enableVibration:   true,
      visibility:        NotificationVisibility.public,
      autoCancel:        true,
      icon:              '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS:     DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body  ?? '',
      details,
      payload: jsonEncode(message.data),
    );
  }

  // =========================================
  // GET TOKEN
  // =========================================
  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("FCM TOKEN : $token");
    return token;
  }
}