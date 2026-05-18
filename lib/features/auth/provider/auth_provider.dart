import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/repositories/auth_repository.dart';
import '../../../features/notifikasi/data/services/notifikasi_service.dart';

/// Mengelola state dan orkestrasi proses autentikasi.
/// Screen hanya listen ke provider ini — tidak ada logika bisnis di screen.
class AuthProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  String? _savedEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get savedEmail => _savedEmail;

  // ── Load kredensial tersimpan ─────────────────────────────────────────────
  /// Dipanggil dari initState LoginScreen.
  Future<void> loadSavedCredentials() async {
    final saved = await AuthRepository.getSavedCredentials();
    if (saved != null) {
      _savedEmail = saved.email;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  /// Mengembalikan role ('guru' / 'siswa') jika berhasil, null jika gagal.
  /// Screen menggunakan return value ini untuk navigasi.
  Future<String?> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (!result.success) {
        _setError(result.errorMessage ?? 'Login gagal');
        return null;
      }

      await AuthRepository.saveSession(
        token: result.token!,
        role: result.role!,
        user: result.user!,
        remember: remember,
      );

      await NotifikasiService.init(); // Inisialisasi notifikasi setelah login
      
      return result.role;
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthRepository.clearSession();
    _savedEmail = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}