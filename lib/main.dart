import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'core/widgets/main_scaffold.dart';          // Siswa
import 'features/guru/presentation/main_guru_scaffold.dart';              // Guru
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // TODO: NotifikasiService.init(); — aktifkan setelah integrasi flutter_local_notifications
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Learning SMKN 1 Tamanan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash':          (_) => const SplashScreen(seenOnboarding: false),
        '/login':           (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password':  (_) => const ResetPasswordScreen(),
        '/otp':             (_) => const OtpScreen(),
        '/home':            (_) => const MainScaffold(),       // Siswa
        '/home-guru':       (_) => const MainGuruScaffold(),   // Guru
      },
    );
  }
}