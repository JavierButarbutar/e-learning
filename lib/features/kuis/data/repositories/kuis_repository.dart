import '../models/kuis_model.dart';
import '../models/soal_model.dart';
import '../services/kuis_service.dart';

class KuisRepository {
  static Future<KuisModel?> getDetailKuis({
    required String token,
    required int kuisId,
  }) async {
    return KuisService.getDetailKuis(token: token, kuisId: kuisId);
  }

  static Future<Map<String, dynamic>> startKuis({
    required String token,
    required int kuisId,
  }) async {
    return KuisService.startKuis(token: token, kuisId: kuisId);
  }

  static Future<Map<String, dynamic>> getSoal({
    required String token,
    required int kuisId,
  }) async {
    return KuisService.getSoal(token: token, kuisId: kuisId);
  }

  static Future<Map<String, dynamic>> submitJawaban({
    required String token,
    required int kuisId,
    required Map<int, dynamic> jawaban,
  }) async {
    return KuisService.submitJawaban(
      token: token,
      kuisId: kuisId,
      jawaban: jawaban,
    );
  }

  static Future<Map<String, dynamic>> getHasil({
    required String token,
    required int kuisId,
  }) async {
    return KuisService.getHasil(token: token, kuisId: kuisId);
  }
}
