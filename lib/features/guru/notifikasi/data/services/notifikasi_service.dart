import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';   // untuk debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/notifikasi_guru_repository.dart'; // sesuaikan import path

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("NOTIF BACKGROUND : ${message.notification?.title}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId   = 'elearning_channel';
  static const _channelName = 'E-Learning Notifikasi';

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Notifikasi jadwal mengajar guru',
            importance: Importance.high,
          ),
        );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM TOKEN: $fcmToken");
    if (fcmToken != null) {
      await NotifikasiGuruRepository.updateFcmToken(fcmToken); // ← ini yang kurang
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle kalau Firebase rotate token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      NotifikasiGuruRepository.updateFcmToken(newToken).catchError((e) {
        print("FCM token refresh failed: $e");
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("NOTIF FOREGROUND : ${message.notification?.title}");
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIF DIKLIK BACKGROUND : ${message.data}");
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("APP DIBUKA DARI NOTIF : ${initialMessage.data}");
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance:      Importance.max,
      priority:        Priority.high,
      playSound:       true,
      enableVibration: true,
      visibility:      NotificationVisibility.public,
      autoCancel:      true,
      icon:            '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body  ?? '',
      const NotificationDetails(
        android: androidDetails,
        iOS:     DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}