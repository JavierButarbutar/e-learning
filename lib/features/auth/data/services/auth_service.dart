import '../../../../core/network/api_service.dart';

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
    final raw = await ApiService.login(
      email: email,
      password: password,
    );

    if (raw['success'] == false) {
      return AuthResult.failure(raw['message'] ?? 'Login gagal');
    }

    final data = raw['data'] ?? {};
    final user = data['user'] ?? {};
    final role = user['role'] ?? '';
    final token = data['token'] ?? '';

    if (role.isEmpty || token.isEmpty) {
      return AuthResult.failure('Response tidak valid dari server');
    }

    // Bangun map user sesuai role yang dikembalikan server
    Map<String, dynamic> userMap;
    if (role == 'siswa') {
      userMap = {
        'role': role,
        'name': user['name'] ?? '-',
        'email': user['email'] ?? '-',
        'foto': user['foto'] ?? '',
        'nis': user['nis'] ?? '-',
        'kelas': user['kelas'] ?? '-',
      };
    } else if (role == 'guru') {
      userMap = {
        'role': role,
        'name': user['name'] ?? '-',
        'email': user['email'] ?? '-',
        'foto': user['foto'] ?? '',
        'nip': user['nip'] ?? '-',
        'nama_mapel': user['nama_mapel'] ?? '-',
        'no_telp': user['no_telp'] ?? '-',
        'alamat': user['alamat'] ?? '-',
      };
    } else {
      return AuthResult.failure('Role tidak dikenali. Hubungi admin.');
    }

    return AuthResult.success(
      token: token,
      role: role,
      user: userMap,
    );
  }
}

// ── Model hasil login ────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;
  final String? role;
  final Map<String, dynamic>? user;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.token,
    this.role,
    this.user,
  });

  factory AuthResult.success({
    required String token,
    required String role,
    required Map<String, dynamic> user,
  }) =>
      AuthResult._(
        success: true,
        token: token,
        role: role,
        user: user,
      );

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}