import '../../../../core/storage/shared_pref.dart';
import '../models/user_model.dart';
import '../models/saved_credentials.dart';

class AuthRepository {
  static Future<void> saveSession({
    required String token,
    required String role,
    required UserModel user,
    required bool remember,
  }) async {
    await SharedPref.saveToken(token);
    await SharedPref.saveUser(user.toMap());
    await SharedPref.saveLogin(
      email: user.email,
      role: role,
      remember: remember,
    );
    await SharedPref.setLogin(true);
  }

  static Future<SavedCredentials?> getSavedCredentials() async {
    final remember = await SharedPref.getRemember();
    if (!remember) return null;

    final email = await SharedPref.getEmail();
    return SavedCredentials(email: email ?? '');
  }

  static Future<void> clearSession() async {
    await SharedPref.setLogin(false);
  }
}

class SavedCredentials {
  final String email;

  const SavedCredentials({required this.email});
}
