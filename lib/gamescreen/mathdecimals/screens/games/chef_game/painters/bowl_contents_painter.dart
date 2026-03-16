import 'package:flutter/material.dart';

/// Custom painter for bowl contents (blended mixture fill).
class BowlContentsPainter extends CustomPainter {
  final double fillHeight;
  final Color fillColor;

  BowlContentsPainter({required this.fillHeight, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (fillHeight <= 0) return;

    final double height = size.height;
    final double topWidth = size.width * 0.95;
    final double bottomWidth = size.width * 0.6 * 0.95;
    final double innerLeftBottom = (size.width - bottomWidth) / 2;
    final double innerRightBottom = (size.width + bottomWidth) / 2;
    final double usableHeight = height - 4;

    final double actualFillHeight = fillHeight.clamp(0.0, usableHeight);
    final double progress = actualFillHeight / usableHeight;
    final double topFillWidth = bottomWidth + (topWidth - bottomWidth) * progress;
    final double topLeft = (size.width - topFillWidth) / 2;
    final double topRight = (size.width + topFillWidth) / 2;
    final double topY = height - 2 - actualFillHeight;

    final path = Path();
    path.moveTo(topLeft, topY);
    path.lineTo(innerLeftBottom, height - 2);
    path.lineTo(innerRightBottom, height - 2);
    path.lineTo(topRight, topY);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor,
        fillColor.withOpacity(0.85),
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant BowlContentsPainter oldDelegate) =>
      oldDelegate.fillHeight != fillHeight || oldDelegate.fillColor != fillColor;
}
