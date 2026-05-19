import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/notifikasi_repository.dart';

// Handler background (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message diterima otomatis oleh sistem, tidak perlu show manual
}

class NotifikasiService {
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // ── Setup local notifications ──────────────────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotif.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // Buat channel Android
    await _localNotif
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'elearning_channel',       // harus sama dengan channel_id di FcmService
            'E-Learning Notifikasi',
            description: 'Notifikasi tugas, materi, presensi, dan kuis',
            importance: Importance.high,
          ),
        );

    // ── Firebase Messaging ─────────────────────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Minta izin (iOS & Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Kirim FCM token ke backend setelah login
    await _registerToken();

    // Foreground message → tampilkan via local notification
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

  // Daftarkan token FCM ke backend
  static Future<void> _registerToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
     print("FCM TOKEN: $fcmToken");
    if (fcmToken != null) {
      await NotifikasiRepository.updateFcmToken(fcmToken);
    }

    // Refresh token otomatis jika berubah
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      NotifikasiRepository.updateFcmToken(newToken);
    });
  }
}