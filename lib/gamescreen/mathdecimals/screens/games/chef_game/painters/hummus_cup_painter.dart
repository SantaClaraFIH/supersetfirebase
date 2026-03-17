import 'package:flutter/material.dart';

/// Custom painter for a cup/bowl with hummus inside (recipe completion visual).
class HummusCupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Cup body: slightly tapered cylinder (trapezoid in 2D), wider at top
    final double cupTopWidth = w * 0.7;
    final double cupBottomWidth = w * 0.5;
    final double cupLeft = (w - cupTopWidth) / 2;
    final double cupBottom = h * 0.92;
    final double cupTop = h * 0.35;
    final double cupHeight = cupBottom - cupTop;

    final Path cupPath = Path()
      ..moveTo(cupLeft + cupTopWidth, cupTop)
      ..lineTo(cupLeft + cupTopWidth + (cupBottomWidth - cupTopWidth) / 2, cupBottom)
      ..lineTo(cupLeft + (cupBottomWidth - cupTopWidth) / 2, cupBottom)
      ..lineTo(cupLeft, cupTop)
      ..close();

    final Paint cupPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.grey.shade200,
          Colors.grey.shade300,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(cupPath, cupPaint);
    final Paint cupStroke = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(cupPath, cupStroke);

    // Hummus inside: dome/fill at top of cup (tan/beige)
    final double hummusTop = cupTop + cupHeight * 0.15;
    final double hummusRadius = cupTopWidth * 0.42;
    final Offset hummusCenter = Offset(w / 2, hummusTop + hummusRadius * 0.4);

    final Rect hummusRect = Rect.fromCircle(center: hummusCenter, radius: hummusRadius);
    final Paint hummusPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          const Color(0xFFD2B48C),
          const Color(0xFFC4A574),
          const Color(0xFF8B7355),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(hummusRect)
      ..style = PaintingStyle.fill;
    canvas.drawOval(hummusRect, hummusPaint);
    final Paint hummusStroke = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(hummusRect, hummusStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
