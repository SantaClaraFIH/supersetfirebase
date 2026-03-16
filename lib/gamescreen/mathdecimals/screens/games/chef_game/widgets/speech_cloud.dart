import 'dart:math';

import 'package:flutter/material.dart';

class SpeechCloud extends StatelessWidget {
  const SpeechCloud({super.key, required this.text});

  final String text;

  static const double _height = 116;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.brown.shade800,
      height: 1.25,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final cloudWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 120.0;
        const contentWidthPadding = 100.0;
        const padding = 12.0;
        // On very narrow screens, shrink the horizontal padding so we never
        // end up with negative or zero content width.
        final horizontalPadding =
            max(0.0, min(contentWidthPadding, (cloudWidth - 20.0) / 2));
        final contentWidth = max(0.0, cloudWidth - horizontalPadding * 2);
        final contentHeight = _height - padding * 2;
        // Limit text width so it doesn't stretch edge-to-edge inside the cloud.
        final textMaxWidth = contentWidth * 0.88;
        return SizedBox(
          width: cloudWidth,
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(cloudWidth, _height),
                painter: CloudShapePainter(),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: padding,
                bottom: padding,
                child: SizedBox(
                  width: contentWidth,
                  height: contentHeight,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: textMaxWidth),
                          child: Text(
                            text,
                            style: textStyle,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -6,
                bottom: _height * 0.3,
                child: CustomPaint(
                  size: const Size(16, 20),
                  painter: SpeechCloudTailPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CloudShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.orange.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(w * 0.15, h * 0.6);
    path.quadraticBezierTo(0, h * 0.5, w * 0.08, h * 0.35);
    path.quadraticBezierTo(w * 0.02, h * 0.15, w * 0.2, h * 0.2);
    path.quadraticBezierTo(w * 0.18, h * 0.05, w * 0.4, h * 0.08);
    path.quadraticBezierTo(w * 0.42, 0, w * 0.55, h * 0.05);
    path.quadraticBezierTo(w * 0.72, h * 0.02, w * 0.78, h * 0.18);
    path.quadraticBezierTo(w * 0.98, h * 0.15, w * 0.92, h * 0.38);
    path.quadraticBezierTo(w, h * 0.5, w * 0.9, h * 0.6);
    path.quadraticBezierTo(w * 0.95, h * 0.82, w * 0.7, h * 0.85);
    path.quadraticBezierTo(w * 0.5, h * 0.95, w * 0.3, h * 0.82);
    path.quadraticBezierTo(w * 0.12, h * 0.88, w * 0.15, h * 0.6);
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.08), 8, true);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpeechCloudTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height * 0.3)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.orange.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

