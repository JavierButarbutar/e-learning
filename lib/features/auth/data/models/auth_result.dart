import 'user_model.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;
  final String? role;
  final UserModel? user;

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
    required UserModel user,
  }) => AuthResult._(success: true, token: token, role: role, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
