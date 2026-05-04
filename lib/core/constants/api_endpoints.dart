class ApiEndpoint {
  static const String baseUrl =
      "https://sacramento-persian-circulation-boundaries.trycloudflare.com/api";

static const login = "$baseUrl/auth/login";
static const checkEmail = "$baseUrl/auth/check-email";
static const sendOtp = "$baseUrl/auth/send-otp";
static const verifyOtp = "$baseUrl/auth/verify-otp";
static const resetPassword = "$baseUrl/auth/reset-password";
}