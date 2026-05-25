import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';

import 'core/widgets/main_scaffold.dart';
import 'features/guru/presentation/main_guru_scaffold.dart';
import 'core/theme/app_theme.dart';

import 'features/mapel/provider/mapel_provider.dart';
import 'features/presensi/provider/presensi_provider.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/kuis/provider/kuis_provider.dart';
import 'features/notifikasi/provider/notifikasi_provider.dart';
import 'features/guru/notifikasi/provider/notifikasi_guru_provider.dart';

import 'features/notifikasi/data/services/notifikasi_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await NotifikasiService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => MapelProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PresensiProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => KuisProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => NotifikasiProvider(),
        ),

        ChangeNotifierProvider(
            create: (_) => NotifikasiGuruProvider(), 
        ),

      ],

      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: navigatorKey,

      title: 'E-Learning SMKN 1 Tamanan',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.theme,

      initialRoute: '/splash',

      routes: {

        '/splash': (_) =>
            const SplashScreen(seenOnboarding: true),

        '/login': (_) =>
            const LoginScreen(),

        '/forgot-password': (_) =>
            const ForgotPasswordScreen(),

        '/reset-password': (_) =>
            const ResetPasswordScreen(),

        '/otp': (_) =>
            const OtpScreen(),

        '/home': (_) =>
            const MainScaffold(),

        '/home-guru': (_) =>
            const MainGuruScaffold(),
      },
    );
  }
}