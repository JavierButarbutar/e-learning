import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/soal_model.dart';
import '../../provider/kuis_provider.dart';

class EsaiWidget extends StatelessWidget {
  final SoalModel soal;

  const EsaiWidget({super.key, required this.soal});

  @override
  Widget build(BuildContext context) {
    final ctrl =
        context.read<KuisProvider>().esaiCtrlFor(soal.idSoal);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 7,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'Poppins',
          color: Color(0xFF333333),
          height: 1.7,
        ),
        onChanged: (v) =>
            context.read<KuisProvider>().updateEsai(soal.idSoal, v),
        decoration: const InputDecoration(
          hintText: 'Tuliskan jawaban Anda di sini...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: Color(0xFFBBBBBB),
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}