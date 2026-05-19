import '../../../../core/storage/shared_pref.dart';

/// Bertanggung jawab untuk semua operasi penyimpanan lokal (SharedPreferences).
/// Screen dan Provider tidak boleh langsung akses SharedPref.
class AuthRepository {
  // ── Simpan session setelah login berhasil ─────────────────────────────────
  static Future<void> saveSession({
    required String token,
    required String role,
    required Map<String, dynamic> user,
    required bool remember,
  }) async {
    await SharedPref.saveToken(token);
    await SharedPref.saveUser(user);
    await SharedPref.saveLogin(
      email: user['email'] ?? '',
      role: role,
      remember: remember,
    );
    await SharedPref.setLogin(true);
  }

  // ── Ambil kredensial tersimpan (untuk fitur "Ingatkan Saya") ──────────────
  /// Mengembalikan [SavedCredentials] jika remember pernah diaktifkan,
  /// atau null jika tidak ada data tersimpan.
  static Future<SavedCredentials?> getSavedCredentials() async {
    final remember = await SharedPref.getRemember();
    if (!remember) return null;

    final email = await SharedPref.getEmail();
    return SavedCredentials(email: email ?? '');
  }

  // ── Hapus session (logout) ────────────────────────────────────────────────
  static Future<void> clearSession() async {
    await SharedPref.setLogin(false);
    // Tambahkan clear token/user jika SharedPref menyediakan method-nya
    // await SharedPref.clearToken();
    // await SharedPref.clearUser();
  }
}

// ── Model kredensial tersimpan ───────────────────────────────────────────────
class SavedCredentials {
  final String email;

  const SavedCredentials({required this.email});
}