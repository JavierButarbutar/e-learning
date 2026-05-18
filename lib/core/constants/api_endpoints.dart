class ApiEndpoint {
  static const String baseUrl =
      "http://192.168.137.1:8000/api";

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
  static const String mapel = "$baseUrl/mapel";

  static String detailMapel(dynamic id) =>
      "$baseUrl/mapel/$id";

  static String materiByMapel(dynamic id) =>
      "$baseUrl/mapel/$id/materi";

  static String detailMateri(dynamic id) =>
      "$baseUrl/materi/$id";
  
  static String uploadTugas(dynamic idTugas) =>
      "$baseUrl/tugas/$idTugas/upload";
  
  static const String tugasSiswa = "$baseUrl/tugas";

  static const String presensiAktif   = '$baseUrl/presensi/active';
  static const String presensiScan    = '$baseUrl/presensi/scan';
  static const String presensiRiwayat = '$baseUrl/presensi/riwayat';
  static const String presensiRekap   = '$baseUrl/presensi/rekap';

  static const String kuis = "$baseUrl/kuis";

  static String detailKuis(dynamic id) => "$baseUrl/kuis/$id";
  static String startKuis(dynamic id)  => "$baseUrl/kuis/$id/start";
  static String soalKuis(dynamic id)   => "$baseUrl/kuis/$id/soal";
  static String submitKuis(dynamic id) => "$baseUrl/kuis/$id/submit";
  static String resultKuis(dynamic id) => "$baseUrl/kuis/$id/result";

  static const String notifikasi =
      "$baseUrl/notifikasi";

  static const String unreadNotifikasi =
      "$baseUrl/notifikasi/unread-count";

  static const String bacaSemuaNotifikasi =
      "$baseUrl/notifikasi/baca-semua";

  static const String updateFcmToken =
      "$baseUrl/notifikasi/update-token";

  static String bacaNotifikasi(dynamic id) =>
      "$baseUrl/notifikasi/$id/baca";
}