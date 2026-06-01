import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class ForceLogoutHelper {
  static Future<void> handle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
      arguments: {'forceLogout': true},
    );
  }
}
