import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final bool seenOnboarding;
  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _logoScale   = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2E7D32),
        child: Stack(children: [
          // Dekoratif lingkaran
          Positioned(top: -80, right: -60,
            child: _circle(280, Colors.white, 0.05)),
          Positioned(bottom: -60, left: -40,
            child: _circle(200, Colors.white, 0.05)),

          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Logo
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF5A623), width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                          blurRadius: 24, offset: const Offset(0, 6))],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo_sekolah.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Teks
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: const Column(children: [
                    Text('E-Learning SMKN 1 Tamanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: Colors.white, fontFamily: 'Poppins',
                          letterSpacing: 0.3)),
                    SizedBox(height: 6),
                    Text('Platform Belajar Digital',
                      style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF),
                          fontFamily: 'Poppins')),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _circle(double size, Color color, double opacity) =>
      Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(opacity), width: 40)));
}