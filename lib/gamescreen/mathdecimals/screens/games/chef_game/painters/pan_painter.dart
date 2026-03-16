import 'package:flutter/material.dart';

/// Custom painter for a frying pan on a stove with pancakes.
class PanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Stove top (backdrop)
    final RRect stoveTop = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.5, w, h * 0.5),
      const Radius.circular(6),
    );
    final Paint stovePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade400,
          Colors.grey.shade600,
        ],
      ).createShader(stoveTop.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(stoveTop, stovePaint);
    final Paint stoveStroke = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(stoveTop, stoveStroke);

    // Burner ring (under the pan)
    final double burnerCx = w * 0.38;
    final double burnerCy = h * 0.72;
    final Paint burnerOuter = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(burnerCx, burnerCy), 22, burnerOuter);
    final Paint burnerInner = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(burnerCx, burnerCy), 16, burnerInner);
    final Paint burnerRing = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(burnerCx, burnerCy), 19, burnerRing);

    // Pan body (oval, sitting on stove) – metallic with gradient
    final Rect panRect = Rect.fromCenter(
      center: Offset(w * 0.38, h * 0.42),
      width: w * 0.5,
      height: h * 0.38,
    );
    final Path panPath = Path()
      ..addOval(panRect);
    final Paint panPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.brown.shade300,
          Colors.brown.shade700,
          Colors.brown.shade800,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(panRect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(panPath, panPaint);
    final Paint panStroke = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(panPath, panStroke);

    // Pan inner (cooking surface) – slightly darker
    final Rect innerRect = Rect.fromCenter(
      center: Offset(w * 0.38, h * 0.42),
      width: w * 0.42,
      height: h * 0.3,
    );
    final Paint innerPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    canvas.drawOval(innerRect, innerPaint);

    // Handle (rounded rect extending right)
    final RRect handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.58, h * 0.32, w * 0.38, h * 0.2),
      const Radius.circular(10),
    );
    final Paint handlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.brown.shade600,
          Colors.brown.shade400,
        ],
      ).createShader(handle.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(handle, handlePaint);
    canvas.drawRRect(handle, panStroke);

    // Pancakes (golden, slightly varied sizes, with soft highlight)
    final List<Offset> pancakeCenters = [
      Offset(w * 0.28, h * 0.4),
      Offset(w * 0.42, h * 0.38),
      Offset(w * 0.36, h * 0.48),
    ];
    final List<double> pancakeRadii = [11, 9, 10];
    for (int i = 0; i < pancakeCenters.length; i++) {
      final Offset c = pancakeCenters[i];
      final double r = pancakeRadii[i];
      // Main pancake color (golden brown)
      final Paint pancakePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.amber.shade200,
            Colors.amber.shade600,
            Colors.amber.shade800,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(c, r, pancakePaint);
      // Edge/darkening
      final Paint edgePaint = Paint()
        ..color = Colors.brown.shade700.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(c, r, edgePaint);
    }

    // Optional: tiny wisp of steam from one pancake
    final Paint steamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.28, h * 0.28),
      Offset(w * 0.26, h * 0.18),
      steamPaint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.26),
      Offset(w * 0.34, h * 0.16),
      steamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
