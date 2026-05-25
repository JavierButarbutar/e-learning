import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/api_service.dart';
import '../models/auth_result.dart';
import '../models/user_model.dart';

/// Bertanggung jawab hanya untuk komunikasi dengan API.
/// Parsing raw response menjadi AuthResult yang bersih.
class AuthService {

  // ── Login ──────────────────────────────────────────────────────────────────
  /// Mengirim email + password ke API.
  /// Role ditentukan dari response server, bukan dari input user.
  static Future<AuthResult> login({
  required String email,
  required String password,
}) async {
  final fcmToken = await FirebaseMessaging.instance.getToken(); // tambah

  final raw = await ApiService.login(
    email: email,
    password: password,
    fcmToken: fcmToken, // tambah
  );
 
    if (raw['success'] == false) {
      return AuthResult.failure(raw['message'] ?? 'Login gagal');
    }
 
    final data = raw['data'] ?? {};
    final userRaw = data['user'] ?? {};
    final token = data['token'] ?? '';
    final role = userRaw['role'] ?? '';
 
    if (role.isEmpty || token.isEmpty) {
      return AuthResult.failure('Response tidak valid dari server');
    }
 
    // Gunakan UserModel.fromMap — otomatis pilih SiswaModel atau GuruModel
    final UserModel user;
    try {
      user = UserModel.fromMap(userRaw);
    } catch (e) {
      return AuthResult.failure('Role tidak dikenali. Hubungi admin.');
    }
 
    return AuthResult.success(
      token: token,
      role: role,
      user: user,
    );
  }
}

// ── Model hasil login ────────────────────────────────────────────────────────
