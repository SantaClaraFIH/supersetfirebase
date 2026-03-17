import 'package:flutter/material.dart';

/// Custom painter for an oven with cookies or cake inside.
class OvenPainter extends CustomPainter {
  final String variant; // 'cookies' | 'cake'

  OvenPainter({required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Oven outer body (appliance shape)
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(10),
    );
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade500,
          Colors.grey.shade700,
          Colors.grey.shade800,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(body.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(body, bodyPaint);
    final Paint bodyStroke = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(body, bodyStroke);

    // Control panel strip at top
    final RRect controlStrip = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.02, w * 0.9, h * 0.12),
      const Radius.circular(6),
    );
    final Paint controlPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawRRect(controlStrip, controlPaint);
    canvas.drawRRect(controlStrip, bodyStroke);
    // Dots / indicators on panel
    final Paint dotPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(w * 0.2 + i * w * 0.15, h * 0.08),
        3,
        dotPaint,
      );
    }

    // Door (recessed) with frame
    final RRect doorFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.06, h * 0.16, w * 0.88, h * 0.78),
      const Radius.circular(8),
    );
    final Paint doorFramePaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;
    canvas.drawRRect(doorFrame, doorFramePaint);
    canvas.drawRRect(doorFrame, bodyStroke);

    // Door glass / window (inner)
    final RRect window = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.35),
      const Radius.circular(4),
    );
    final Paint windowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade100.withValues(alpha: 0.5),
          Colors.blue.shade200.withValues(alpha: 0.35),
          Colors.blue.shade300.withValues(alpha: 0.2),
        ],
      ).createShader(window.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(window, windowPaint);
    final Paint windowStroke = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(window, windowStroke);

    // Door handle (horizontal bar below window)
    final RRect handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, h * 0.58, w * 0.3, h * 0.06),
      const Radius.circular(4),
    );
    final Paint handlePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    canvas.drawRRect(handle, handlePaint);
    canvas.drawRRect(handle, bodyStroke);

    // Interior (below window) – darker cavity
    final RRect interior = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.32),
      const Radius.circular(4),
    );
    final Paint interiorPaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.fill;
    canvas.drawRRect(interior, interiorPaint);

    if (variant == 'cookies') {
      // Baking sheet / tray
      final RRect tray = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.62, w * 0.72, h * 0.14),
        const Radius.circular(2),
      );
      final Paint trayPaint = Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.fill;
      canvas.drawRRect(tray, trayPaint);
      final Paint trayStroke = Paint()
        ..color = Colors.grey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(tray, trayStroke);

      // Cookies (golden brown circles, slightly irregular feel with stroke)
      final List<Offset> cookiePositions = [
        Offset(w * 0.22, h * 0.69),
        Offset(w * 0.38, h * 0.69),
        Offset(w * 0.54, h * 0.69),
        Offset(w * 0.7, h * 0.69),
      ];
      final Paint cookiePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.amber.shade300,
            Colors.brown.shade600,
            Colors.brown.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill;
      final Paint cookieStroke = Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (final Offset pos in cookiePositions) {
        canvas.drawCircle(pos, 10, cookiePaint);
        canvas.drawCircle(pos, 10, cookieStroke);
      }
    } else {
      // Cake variant: round pan with domed cake
      final double cx = w * 0.5;
      final double cy = h * 0.7;
      // Pan (metal ring)
      final Paint panPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade600,
            Colors.grey.shade800,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 26))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 26, panPaint);
      final Paint panStroke = Paint()
        ..color = Colors.grey.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), 26, panStroke);
      // Cake (domed top – darker chocolate)
      final Paint cakePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Colors.brown.shade400,
            Colors.brown.shade600,
            Colors.brown.shade800,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 22))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 22, cakePaint);
      final Paint cakeStroke = Paint()
        ..color = Colors.brown.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(cx, cy), 22, cakeStroke);
    }
  }

  @override
  bool shouldRepaint(covariant OvenPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
