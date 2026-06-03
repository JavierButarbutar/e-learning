import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/notifikasi_guru_repository.dart';
import '../../../../../core/storage/shared_pref.dart';
import '../../provider/notifikasi_guru_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('NOTIF BACKGROUND: ${message.notification?.title}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'elearning_channel';
  static const _channelName = 'E-Learning Notifikasi';

  static Future<void> initialize({NotifikasiGuruProvider? provider}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _localNotifications
    .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >()
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
    debugPrint('FCM TOKEN: $fcmToken');

    if (fcmToken != null) {
      // Hanya kirim ke server kalau token berubah
      final savedToken = await SharedPref.getFcmToken();
      if (savedToken != fcmToken) {
        await NotifikasiGuruRepository.updateFcmToken(fcmToken);
        await SharedPref.saveFcmToken(fcmToken);
        debugPrint('FCM TOKEN: updated to server');
      } else {
        debugPrint('FCM TOKEN: sama, skip update ke server');
      }
    }

    // Token refresh = pasti beda, langsung update
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await NotifikasiGuruRepository.updateFcmToken(newToken);
        await SharedPref.saveFcmToken(newToken);
        debugPrint('FCM TOKEN: refreshed and saved');
      } catch (e) {
        debugPrint('FCM token refresh failed: $e');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('NOTIF FOREGROUND: ${message.notification?.title}');

      // Update badge tanpa hit API
      provider?.incrementUnreadCount();

      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('NOTIF DIKLIK BACKGROUND: ${message.data}');
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('APP DIBUKA DARI NOTIF: ${initialMessage.data}');
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}