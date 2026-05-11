import 'dart:async';
import 'package:flutter/material.dart';

// ── Model soal ────────────────────────────────────────────────
enum TipeSoal { pilihanGanda, esai }

class SoalModel {
  final int nomor;
  final String pertanyaan;
  final TipeSoal tipe;
  final List<String>? pilihan; // untuk pilihan ganda
  const SoalModel({
    required this.nomor,
    required this.pertanyaan,
    required this.tipe,
    this.pilihan,
  });
}

// ── Dummy soal ────────────────────────────────────────────────
final _dummySoal = [
  SoalModel(
    nomor: 1,
    tipe: TipeSoal.pilihanGanda,
    pertanyaan: 'Hormon apa yang paling berperan penting dalam proses ovulasi pada sistem reproduksi wanita?',
    pilihan: ['Hormon Estrogen', 'Hormon Luteinizing (LH)', 'Hormon Progesteron', 'Hormon Follicle Stimulating (FSH)'],
  ),
  SoalModel(
    nomor: 2,
    tipe: TipeSoal.pilihanGanda,
    pertanyaan: 'Proses pembuahan sel telur oleh sperma disebut...',
    pilihan: ['Fertilisasi', 'Implantasi', 'Gestasi', 'Ovulasi'],
  ),
  SoalModel(
    nomor: 3,
    tipe: TipeSoal.pilihanGanda,
    pertanyaan: 'Organ manakah yang berfungsi sebagai tempat berkembangnya janin?',
    pilihan: ['Ovarium', 'Tuba Falopi', 'Uterus', 'Vagina'],
  ),
  SoalModel(
    nomor: 4,
    tipe: TipeSoal.esai,
    pertanyaan: 'Jelaskan perbedaan antara mitosis dan meiosis beserta fungsinya masing-masing dalam proses reproduksi!',
  ),
  SoalModel(
    nomor: 5,
    tipe: TipeSoal.pilihanGanda,
    pertanyaan: 'Sel yang dihasilkan dari proses meiosis bersifat...',
    pilihan: ['Diploid (2n)', 'Haploid (n)', 'Triploid (3n)', 'Tetraploid (4n)'],
  ),
  SoalModel(
    nomor: 6,
    tipe: TipeSoal.esai,
    pertanyaan: 'Uraikan tahapan-tahapan siklus menstruasi dan jelaskan peran hormon dalam setiap tahapannya!',
  ),
];

// ─────────────────────────────────────────────────────────────
class KuisScreen extends StatefulWidget {
  final String judulKuis;
  final int durasiMenit;
  final String namaMapel;

  const KuisScreen({
    super.key,
    this.judulKuis = 'Kuis Evaluasi 1',
    this.durasiMenit = 15,
    this.namaMapel = 'Organ Reproduksi',
  });

  @override
  State<KuisScreen> createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> {
  int _currentSoal = 0;
  final Map<int, String> _jawaban = {}; // nomor soal → jawaban
  final Map<int, TextEditingController> _esaiCtrl = {};
  late int _sisaDetik;
  Timer? _timer;
  bool _selesai = false;

  @override
  void initState() {
    super.initState();
    _sisaDetik = widget.durasiMenit * 60;
    _startTimer();
    for (var s in _dummySoal) {
      if (s.tipe == TipeSoal.esai) {
        _esaiCtrl[s.nomor] = TextEditingController();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisaDetik <= 0) {
        t.cancel();
        _submitKuis();
      } else {
        setState(() => _sisaDetik--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _esaiCtrl.values) c.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final m = _sisaDetik ~/ 60;
    final s = _sisaDetik % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_sisaDetik < 60) return const Color(0xFFE53935);
    if (_sisaDetik < 180) return const Color(0xFFF5A623);
    return const Color(0xFF2E7D32);
  }

  void _pilihJawaban(String val) {
    setState(() => _jawaban[_dummySoal[_currentSoal].nomor] = val);
  }

  void _next() {
    if (_currentSoal < _dummySoal.length - 1) {
      setState(() => _currentSoal++);
    } else {
      _submitKuis();
    }
  }

  void _prev() {
    if (_currentSoal > 0) setState(() => _currentSoal--);
  }

  void _submitKuis() {
    _timer?.cancel();
    setState(() => _selesai = true);
    _showResultDialog();
  }

  void _showResultDialog() {
    final terjawab = _jawaban.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE8F5E9)),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Kuis Selesai!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins', color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            Text('$terjawab dari ${_dummySoal.length} soal dijawab',
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888),
                  fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soal = _dummySoal[_currentSoal];
    final isLast = _currentSoal == _dummySoal.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // ── Header ──
        Container(
          color: const Color(0xFF2E7D32),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 14),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => _showExitDialog(),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.judulKuis,
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          fontFamily: 'Poppins')),
                    Text(widget.namaMapel,
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Poppins')),
                  ]),
              ),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Icon(Icons.timer_outlined, size: 15, color: _timerColor),
                  const SizedBox(width: 4),
                  Text(_timerLabel,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: _timerColor, fontFamily: 'Poppins')),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            // Progress soal
            Row(children: [
              Text('Soal ${_currentSoal + 1}/${_dummySoal.length}',
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Poppins')),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentSoal + 1) / _dummySoal.length,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF5A623)),
                    minHeight: 6,
                  ),
                ),
              ),
            ]),
          ]),
        ),

        // ── Konten soal ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor & tipe soal
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Soal ${soal.nomor}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white, fontFamily: 'Poppins')),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: soal.tipe == TipeSoal.pilihanGanda
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      soal.tipe == TipeSoal.pilihanGanda ? 'Pilihan Ganda' : 'Esai',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: soal.tipe == TipeSoal.pilihanGanda
                              ? const Color(0xFF1E88E5)
                              : const Color(0xFFF5A623))),
                  ),
                ]),
                const SizedBox(height: 14),

                // Pertanyaan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Text(soal.pertanyaan,
                    style: const TextStyle(fontSize: 14,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins',
                        height: 1.7)),
                ),
                const SizedBox(height: 14),

                // Pilihan jawaban atau field esai
                if (soal.tipe == TipeSoal.pilihanGanda)
                  ...List.generate(soal.pilihan!.length, (i) {
                    final label = String.fromCharCode(65 + i); // A, B, C, D
                    final isSelected = _jawaban[soal.nomor] == soal.pilihan![i];
                    return GestureDetector(
                      onTap: () => _pilihJawaban(soal.pilihan![i]),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFEEEEEE),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFF5F5F5),
                            ),
                            child: Center(
                              child: Text(label,
                                style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Poppins',
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF888888))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(soal.pilihan![i],
                              style: TextStyle(fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: isSelected
                                      ? FontWeight.w600 : FontWeight.w400,
                                  color: const Color(0xFF1A1A1A))),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32), size: 20),
                        ]),
                      ),
                    );
                  })
                else ...[
                  // Field esai
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: TextField(
                      controller: _esaiCtrl[soal.nomor],
                      maxLines: 7,
                      style: const TextStyle(fontSize: 13, fontFamily: 'Poppins',
                          color: Color(0xFF333333), height: 1.7),
                      onChanged: (v) => _jawaban[soal.nomor] = v,
                      decoration: const InputDecoration(
                        hintText: 'Tuliskan jawaban Anda di sini...',
                        hintStyle: TextStyle(fontSize: 13,
                            color: Color(0xFFBBBBBB), fontFamily: 'Poppins'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],

                // Nomor soal navigator
                const SizedBox(height: 20),
                const Text('Navigasi Soal',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: Color(0xFF888888), fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: List.generate(_dummySoal.length, (i) {
                    final isCurrent = i == _currentSoal;
                    final isAnswered = _jawaban.containsKey(_dummySoal[i].nomor);
                    return GestureDetector(
                      onTap: () => setState(() => _currentSoal = i),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isCurrent
                              ? const Color(0xFF2E7D32)
                              : isAnswered
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF2E7D32)
                                : isAnswered
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFDDDDDD),
                          ),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: isCurrent
                                    ? Colors.white
                                    : isAnswered
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF888888))),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // ── Tombol navigasi bawah ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          color: Colors.white,
          child: Row(children: [
            if (_currentSoal > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _prev,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Sebelumnya',
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _next,
                icon: Icon(isLast
                    ? Icons.check_circle_outline_rounded
                    : Icons.chevron_right_rounded),
                label: Text(isLast ? 'Selesaikan Kuis' : 'Selanjutnya',
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast
                      ? const Color(0xFFF5A623)
                      : const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Kuis?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
        content: const Text('Jawaban yang sudah diisi tidak akan tersimpan.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Lanjut Kuis',
              style: TextStyle(color: Color(0xFF2E7D32), fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}