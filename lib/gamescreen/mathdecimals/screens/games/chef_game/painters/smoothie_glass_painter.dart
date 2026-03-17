import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for a glass of smoothie with a straw and a small umbrella.
class SmoothieGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Glass body: trapezoid (wider at top), with rounded corners feel via rect
    final double glassTopWidth = w * 0.55;
    final double glassBottomWidth = w * 0.4;
    final double glassLeft = (w - glassTopWidth) / 2;
    final double glassTop = h * 0.12;
    final double glassBottom = h * 0.88;
    final double glassHeight = glassBottom - glassTop;

    final Path glassPath = Path()
      ..moveTo(glassLeft, glassTop)
      ..lineTo(glassLeft + (glassTopWidth - glassBottomWidth) / 2, glassBottom)
      ..lineTo(glassLeft + glassTopWidth - (glassTopWidth - glassBottomWidth) / 2, glassBottom)
      ..lineTo(glassLeft + glassTopWidth, glassTop)
      ..close();

    final Paint glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.blue.shade50.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(glassPath, glassPaint);
    final Paint glassStroke = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(glassPath, glassStroke);

    // Smoothie liquid inside (gradient: berry/purple at bottom, lighter at top)
    final double liquidTop = glassTop + glassHeight * 0.18;
    final double liquidBottom = glassBottom - 4;
    final double liquidTopW = glassTopWidth * 0.88;
    final double liquidBottomW = glassBottomWidth * 0.88;
    final double liquidLeft = (w - liquidTopW) / 2;

    final Path liquidPath = Path()
      ..moveTo(liquidLeft, liquidTop)
      ..lineTo(
        liquidLeft + (liquidTopW - liquidBottomW) / 2,
        liquidBottom,
      )
      ..lineTo(
        liquidLeft + liquidTopW - (liquidTopW - liquidBottomW) / 2,
        liquidBottom,
      )
      ..lineTo(liquidLeft + liquidTopW, liquidTop)
      ..close();

    final Paint liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE8B4D4),
          const Color(0xFF9B59B6),
          const Color(0xFF4A0E4E),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, liquidTop, w, liquidBottom - liquidTop))
      ..style = PaintingStyle.fill;
    canvas.drawPath(liquidPath, liquidPaint);

    // Straw: angled rectangle, entering top-right of glass
    final double strawCx = w * 0.68;
    final double strawTopY = -h * 0.05;
    final double strawBottomY = h * 0.5;
    final double strawWidth = 4;
    final Path strawPath = Path()
      ..moveTo(strawCx - strawWidth / 2, strawTopY)
      ..lineTo(strawCx + strawWidth / 2, strawTopY + 8)
      ..lineTo(strawCx + strawWidth / 2, strawBottomY + 8)
      ..lineTo(strawCx - strawWidth / 2, strawBottomY)
      ..close();
    final Paint strawPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.red.shade400,
          Colors.red.shade700,
        ],
      ).createShader(Rect.fromLTWH(strawCx - 4, strawTopY, 8, strawBottomY - strawTopY + 10))
      ..style = PaintingStyle.fill;
    canvas.drawPath(strawPath, strawPaint);
    final Paint strawStroke = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(strawPath, strawStroke);

    // Small umbrella: pole and canopy above the glass
    final double umbrellaCx = w * 0.72;
    final double umbrellaPoleTop = h * 0.08;
    final double umbrellaPoleBottom = h * 0.22;
    final Paint polePaint = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(umbrellaCx, umbrellaPoleTop),
      Offset(umbrellaCx, umbrellaPoleBottom),
      polePaint,
    );

    // Umbrella canopy: small arc or triangle segments (simplified as a small filled arc/circle)
    final double canopyRadius = 14;
    final Offset canopyCenter = Offset(umbrellaCx, umbrellaPoleTop - 2);
    final Paint canopyPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [
          Colors.orange.shade300,
          Colors.orange.shade600,
          Colors.orange.shade800,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: canopyCenter, radius: canopyRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(canopyCenter, canopyRadius, canopyPaint);
    final Paint canopyStroke = Paint()
      ..color = Colors.orange.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(canopyCenter, canopyRadius, canopyStroke);

    // Umbrella ribs: short lines from center toward edge to suggest folds
    final Paint ribPaint = Paint()
      ..color = Colors.orange.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      final double angle = -math.pi / 2 + (i / 8) * math.pi;
      canvas.drawLine(
        canopyCenter,
        Offset(
          canopyCenter.dx + canopyRadius * 0.85 * math.cos(angle),
          canopyCenter.dy + canopyRadius * 0.85 * math.sin(angle),
        ),
        ribPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
