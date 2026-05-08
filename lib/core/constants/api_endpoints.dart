class ApiEndpoint {
  static const String baseUrl =
      "https://clips-visitor-microphone-aimed.trycloudflare.com/api";

  static const login = "$baseUrl/auth/login";
  static const checkEmail = "$baseUrl/auth/check-email";
  static const sendOtp = "$baseUrl/auth/send-otp";
  static const verifyOtp = "$baseUrl/auth/verify-otp";
  static const resetPassword = "$baseUrl/auth/reset-password";
  static const logout = "$baseUrl/auth/logout";
  static const studentProfile = "$baseUrl/student/profile";
  static const updateStudentProfile = "$baseUrl/student/profile/update";
  static const String updatePassword = "$baseUrl/update-password";
  static const String updateEmail = "$baseUrl/update-email";
}