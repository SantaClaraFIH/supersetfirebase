import 'package:flutter/material.dart';

/// Custom painter for U-shape bowl cross-section.
class BowlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.brown.shade300,
        Colors.brown.shade600,
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    double topWidth = size.width;
    double bottomWidth = size.width * 0.6;
    double height = size.height;
    double leftStart = (size.width - topWidth) / 2;
    double rightStart = (size.width + topWidth) / 2;
    double leftBottom = (size.width - bottomWidth) / 2;
    double rightBottom = (size.width + bottomWidth) / 2;

    path.moveTo(leftStart, 0);
    path.quadraticBezierTo(
      leftStart + (leftBottom - leftStart) * 0.5,
      height * 0.3,
      leftBottom,
      height,
    );
    path.lineTo(rightBottom, height);
    path.quadraticBezierTo(
      rightBottom + (rightStart - rightBottom) * 0.5,
      height * 0.3,
      rightStart,
      0,
    );
    path.lineTo(leftStart, 0);
    path.close();

    canvas.drawPath(path, paint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.shade800
      ..strokeWidth = 3;
    canvas.drawPath(path, rimPaint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.shade200.withOpacity(0.5)
      ..strokeWidth = 1;

    final innerPath = Path();
    double innerTopWidth = topWidth * 0.95;
    double innerBottomWidth = bottomWidth * 0.95;
    double innerLeftStart = (size.width - innerTopWidth) / 2;
    double innerRightStart = (size.width + innerTopWidth) / 2;
    double innerLeftBottom = (size.width - innerBottomWidth) / 2;
    double innerRightBottom = (size.width + innerBottomWidth) / 2;

    innerPath.moveTo(innerLeftStart, 2);
    innerPath.quadraticBezierTo(
      innerLeftStart + (innerLeftBottom - innerLeftStart) * 0.5,
      height * 0.3,
      innerLeftBottom,
      height - 2,
    );
    innerPath.lineTo(innerRightBottom, height - 2);
    innerPath.quadraticBezierTo(
      innerRightBottom + (innerRightStart - innerRightBottom) * 0.5,
      height * 0.3,
      innerRightStart,
      2,
    );
    innerPath.lineTo(innerLeftStart, 2);
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
