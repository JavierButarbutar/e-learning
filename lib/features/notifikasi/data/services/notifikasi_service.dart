import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/notifikasi_repository.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../provider/notifikasi_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotifikasiService {
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init({NotifikasiProvider? provider}) async {
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
        .resolvePlatformSpecificImplementation <
           AndroidFlutterLocalNotificationsPlugin >()
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
      // Hanya kirim ke server kalau token berubah dari yang tersimpan lokal
      final savedToken = await SharedPref.getFcmToken();
      if (savedToken != fcmToken) {
        await NotifikasiRepository.updateFcmToken(fcmToken);
        await SharedPref.saveFcmToken(fcmToken);
        debugPrint("FCM TOKEN: updated to server");
      } else {
        debugPrint("FCM TOKEN: sama, skip update ke server");
      }
    }

    // Token refresh = pasti beda, langsung update tanpa cek lokal
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await NotifikasiRepository.updateFcmToken(newToken);
        await SharedPref.saveFcmToken(newToken);
        debugPrint("FCM TOKEN: refreshed and saved");
      } catch (e) {
        debugPrint("FCM token refresh failed: $e");
      }
    });

    // Terima notifikasi saat app foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif == null) return;

      // Update badge tanpa hit API
      provider?.incrementUnreadCount();

      _localNotif.show(
        message.hashCode,
        notif.title,
        notif.body,
        const NotificationDetails(
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
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }
}