import 'dart:math';

import 'package:flutter/material.dart';

class ChefNarrator extends StatelessWidget {
  const ChefNarrator({
    super.key,
    this.size = 88,
    this.expression = 'neutral',
  });

  final double size;
  final String expression;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: ChefNarratorPainter(expression: expression),
        size: Size(size, size * 1.25),
      ),
    );
  }
}

class ChefNarratorPainter extends CustomPainter {
  ChefNarratorPainter({this.expression = 'neutral'});

  final String expression;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.5;

    // Body (chef coat – darker)
    final bodyTop = h * 0.4;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, bodyTop, w * 0.7, h * 0.55),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF5D4037));

    // Apron (white front)
    final apronRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, bodyTop + h * 0.06, w * 0.44, h * 0.4),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(apronRect, Paint()..color = Colors.white);

    // Face (skin)
    final faceY = h * 0.34;
    final faceRadius = w * 0.26;
    canvas.drawCircle(
      Offset(centerX, faceY),
      faceRadius,
      Paint()..color = const Color(0xFFFFDBAC),
    );

    // Chef hat – classic toque blanche: tall cylindrical shape, rounded top
    final hatBandTop = faceY - faceRadius * 0.48;
    final hatBandH = h * 0.055;
    final hatCylinderH = h * 0.28;
    final hatTop = hatBandTop - hatCylinderH;
    final hatLeft = centerX - w * 0.36;
    final hatWidth = w * 0.72;
    final outlinePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final hatWhite = Paint()..color = Colors.white;
    // Band at base (where toque sits on head)
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(hatLeft, hatBandTop, hatWidth, hatBandH),
      Radius.circular(hatBandH * 0.5),
    );
    canvas.drawRRect(bandRect, hatWhite);
    canvas.drawRRect(bandRect, outlinePaint);
    // Tall toque body: rounded rect (rounded top, slightly rounded bottom to meet band)
    final toqueRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(hatLeft, hatTop, hatWidth, hatCylinderH),
      topLeft: Radius.circular(hatWidth * 0.42),
      topRight: Radius.circular(hatWidth * 0.42),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(toqueRect, hatWhite);
    canvas.drawRRect(toqueRect, outlinePaint);
    // Vertical pleat lines (classic toque detail)
    final pleatPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 3; i++) {
      final x = hatLeft + hatWidth * (i / 4.0);
      canvas.drawLine(
        Offset(x, hatBandTop - 1),
        Offset(x, hatTop + hatCylinderH * 0.35),
        pleatPaint,
      );
    }

    // Eyes
    final eyeY = faceY - h * 0.02;
    final eyeR = w * 0.045;
    canvas.drawCircle(
      Offset(centerX - w * 0.11, eyeY),
      eyeR,
      Paint()..color = const Color(0xFF3E2723),
    );
    canvas.drawCircle(
      Offset(centerX + w * 0.11, eyeY),
      eyeR,
      Paint()..color = const Color(0xFF3E2723),
    );

    // Mouth: happy = smile + teeth, sad = frown, neutral = slight smile
    final mouthRect = Rect.fromCenter(
      center: Offset(centerX, faceY + h * 0.05),
      width: w * 0.18,
      height: h * 0.035,
    );
    final mouthPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final isSad = expression == 'sad';
    final isHappy = expression == 'happy';
    if (isSad) {
      canvas.drawArc(mouthRect, 0.8 * pi, 0.6 * pi, false, mouthPaint);
    } else {
      canvas.drawArc(mouthRect, 0.2 * pi, 0.6 * pi, false, mouthPaint);
      if (isHappy) {
        // Teeth: small white rectangles along the smile
        final toothW = w * 0.028;
        final toothH = h * 0.018;
        final toothGap = w * 0.006;
        final startX = centerX - 1.5 * (toothW + toothGap);
        final toothY = faceY + h * 0.048;
        final toothPaint = Paint()..color = Colors.white;
        for (int i = 0; i < 4; i++) {
          final x = startX + i * (toothW + toothGap);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(x, toothY),
                width: toothW,
                height: toothH,
              ),
              Radius.circular(w * 0.004),
            ),
            toothPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChefNarratorPainter oldDelegate) =>
      oldDelegate.expression != expression;
}

