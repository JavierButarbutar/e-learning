import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/repositories/auth_repository.dart';
import '../../../features/notifikasi/data/services/notifikasi_service.dart';
import '../../../features/guru/notifikasi/data/services/notifikasi_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _savedEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get savedEmail => _savedEmail;

  Future<void> loadSavedCredentials() async {
    final saved = await AuthRepository.getSavedCredentials();
    if (saved != null) {
      _savedEmail = saved.email;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.login(email: email, password: password);

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

      await NotifikasiService.init();
      if (result.role == 'guru') {
        await NotificationService.initialize();
      }

      return result.role;
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await AuthRepository.clearSession();
    _savedEmail = null;
    notifyListeners();
  }

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
