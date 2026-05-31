import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/storage/shared_pref.dart';
import '../data/models/kuis_model.dart';
import '../data/models/soal_model.dart';
import '../data/repositories/kuis_repository.dart';

class KuisProvider extends ChangeNotifier {
  KuisModel? _kuis;
  SesiKuisModel? _sesi;
  int _currentSoal = 0;

  final Map<int, dynamic> _jawaban = {};
  final Map<int, TextEditingController> _esaiCtrl = {};

  int _sisaDetik = 0;
  Timer? _timer;

  bool _isLoading = false;
  bool _selesai = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _jumlahKeluar = 0;
  static const int _batasAutoSubmit = 3;

  Map<String, dynamic>? _hasilSubmit;

  KuisModel? get kuis => _kuis;
  SesiKuisModel? get sesi => _sesi;
  List<SoalModel> get soalList => _kuis?.soalList ?? [];
  int get currentSoal => _currentSoal;
  Map<int, dynamic> get jawaban => _jawaban;
  int get sisaDetik => _sisaDetik;
  bool get isLoading => _isLoading;
  bool get selesai => _selesai;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get jumlahKeluar => _jumlahKeluar;
  Map<String, dynamic>? get hasilSubmit => _hasilSubmit;

  SoalModel? get soalSekarang =>
      soalList.isNotEmpty ? soalList[_currentSoal] : null;

  bool get isLastSoal => _currentSoal == soalList.length - 1;

  TextEditingController? esaiCtrlFor(int idSoal) => _esaiCtrl[idSoal];

  bool sudahDijawab(int idSoal) => _jawaban.containsKey(idSoal);

  int get jumlahTerjawab {
    for (final entry in _esaiCtrl.entries) {
      final teks = entry.value.text.trim();
      if (teks.isNotEmpty) {
        _jawaban[entry.key] = teks;
      }
    }
    return _jawaban.length;
  }

  bool get tampilkanPeringatan =>
      _jumlahKeluar > 0 && _jumlahKeluar < _batasAutoSubmit;

  int get sisaKesempatan => _batasAutoSubmit - _jumlahKeluar;

  String get timerLabel {
    final m = _sisaDetik ~/ 60;
    final s = _sisaDetik % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get timerColor {
    if (_sisaDetik < 60) return const Color(0xFFE53935);
    if (_sisaDetik < 180) return const Color(0xFFF5A623);
    return const Color(0xFF2E7D32);
  }

  Future<void> initKuis({required int kuisId}) async {
    _setLoading(true);
    _errorMessage = null;
    _selesai = false;
    _isSubmitting = false;
    _jumlahKeluar = 0;
    _jawaban.clear();
    _currentSoal = 0;

    try {
      final token = await SharedPref.getToken() ?? '';

      _kuis = await KuisRepository.getDetailKuis(token: token, kuisId: kuisId);
      if (_kuis == null) {
        _errorMessage = 'Kuis tidak ditemukan';
        return;
      }

      final startResult = await KuisRepository.startKuis(
        token: token,
        kuisId: kuisId,
      );
      if (startResult['success'] != true) {
        _errorMessage = startResult['message'] ?? 'Gagal memulai kuis';
        return;
      }
      _sesi = SesiKuisModel.fromJson(startResult['data']);

      final soalResult = await KuisRepository.getSoal(
        token: token,
        kuisId: kuisId,
      );
      if (soalResult['success'] != true) {
        _errorMessage = soalResult['message'] ?? 'Gagal mengambil soal';
        return;
      }

      final soalList = soalResult['soalList'] as List<SoalModel>;
      _kuis = _kuis!.copyWithSoal(soalList);

      final jawabanTersimpan =
          soalResult['jawabanTersimpan'] as Map<int, dynamic>? ?? {};
      _jawaban.addAll(jawabanTersimpan);

      _esaiCtrl.clear();
      for (final s in soalList) {
        if (s.tipe == TipeSoal.esai) {
          _esaiCtrl[s.idSoal] = TextEditingController(
            text: _jawaban[s.idSoal]?.toString() ?? '',
          );
        }
      }

      _sisaDetik = _sesi!.sisaDetik;
      _currentSoal = 0;
      _startTimer();
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisaDetik <= 0) {
        t.cancel();
        submitKuis(autoSubmit: true);
      } else {
        _sisaDetik--;
        notifyListeners();
      }
    });
  }

  void next() {
    if (!isLastSoal) {
      _currentSoal++;
      notifyListeners();
    }
  }

  void prev() {
    if (_currentSoal > 0) {
      _currentSoal--;
      notifyListeners();
    }
  }

  void goToSoal(int index) {
    if (index >= 0 && index < soalList.length) {
      _currentSoal = index;
      notifyListeners();
    }
  }

  void pilihJawaban(int idSoal, int idPilihan) {
    _jawaban[idSoal] = idPilihan;
    notifyListeners();
  }

  void updateEsai(int idSoal, String teks) {
    if (teks.trim().isEmpty) {
      _jawaban.remove(idSoal);
    } else {
      _jawaban[idSoal] = teks.trim();
    }
  }

  Future<bool> onAppBackground() async {
    if (_selesai || _isSubmitting) return _selesai;

    _jumlahKeluar++;
    notifyListeners();

    if (_jumlahKeluar >= _batasAutoSubmit) {
      _syncEsaiBeforeSubmit();
      await submitKuis(autoSubmit: true);
      return true;
    }
    return false;
  }

  void _syncEsaiBeforeSubmit() {
    for (final entry in _esaiCtrl.entries) {
      final teks = entry.value.text.trim();
      if (teks.isNotEmpty) {
        _jawaban[entry.key] = teks;
      } else {
        _jawaban.remove(entry.key);
      }
    }
  }

  Future<void> submitKuis({bool autoSubmit = false}) async {
    if (_isSubmitting || _selesai) return;
    _isSubmitting = true;

    _timer?.cancel();
    _syncEsaiBeforeSubmit();

    _selesai = true;
    notifyListeners();

    try {
      final token = await SharedPref.getToken() ?? '';

      final result = await KuisRepository.submitJawaban(
        token: token,
        kuisId: _kuis?.id ?? 0,
        jawaban: Map<int, dynamic>.from(_jawaban),
      );

      if (result['success'] == true) {
        _hasilSubmit = result['data'] as Map<String, dynamic>?;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Gagal submit: $e';
    } finally {
      _isSubmitting = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _esaiCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
