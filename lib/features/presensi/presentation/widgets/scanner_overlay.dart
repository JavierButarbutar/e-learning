import 'package:flutter/material.dart';

class OverlayPainter extends CustomPainter {
  final double frameSize;
  final double centerY;

  const OverlayPainter({required this.frameSize, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black.withOpacity(0.65);
    final cx = size.width / 2;
    final cy = centerY;
    final h = frameSize / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cy - h), p);
    canvas.drawRect(Rect.fromLTWH(0, cy + h, size.width, size.height), p);
    canvas.drawRect(Rect.fromLTWH(0, cy - h, cx - h, frameSize), p);
    canvas.drawRect(Rect.fromLTWH(cx + h, cy - h, size.width, frameSize), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class FramePainter extends CustomPainter {
  final double len;
  final double radius;
  final Paint framePaint;

  FramePainter({
    required this.len,
    required this.radius,
    required this.framePaint,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final corners = [
      [Offset(0, len), Offset(0, radius), Offset(radius, 0), Offset(len, 0)],

      [
        Offset(s.width - len, 0),
        Offset(s.width - radius, 0),
        Offset(s.width, radius),
        Offset(s.width, len),
      ],

      [
        Offset(s.width, s.height - len),
        Offset(s.width, s.height - radius),
        Offset(s.width - radius, s.height),
        Offset(s.width - len, s.height),
      ],

      [
        Offset(len, s.height),
        Offset(radius, s.height),
        Offset(0, s.height - radius),
        Offset(0, s.height - len),
      ],
    ];

    for (final c in corners) {
      canvas.drawLine(c[0], c[1], framePaint);
      canvas.drawLine(c[2], c[3], framePaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
