import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/notifikasi_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotifikasiService {
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'elearning_channel',
            'E-Learning Notifikasi',
            description: 'Notifikasi tugas, materi, presensi, dan kuis',
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
      await NotifikasiRepository.updateFcmToken(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      NotifikasiRepository.updateFcmToken(newToken).catchError((e) {
        print("FCM token refresh failed: $e");
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif == null) return;

      _localNotif.show(
        message.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'elearning_channel',
            'E-Learning Notifikasi',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });
  }
}
