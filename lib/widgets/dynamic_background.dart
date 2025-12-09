import 'package:flutter/material.dart';
import 'dart:math';

class DynamicBackground extends StatefulWidget {
  final bool isDarkMode;
  final List<Color> gradientColors;
  final double screenWidth;
  final double screenHeight;

  const DynamicBackground({
    super.key,
    required this.isDarkMode,
    required this.gradientColors,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _lightController;
  late AnimationController _waveController;

  late Animation<double> _gradientAnimation;
  late Animation<double> _lightAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _lightController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _lightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lightController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _lightController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_gradientAnimation, _lightAnimation, _waveAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: DynamicBackgroundPainter(
            gradientColors: widget.gradientColors,
            gradientAnimation: _gradientAnimation.value,
            lightAnimation: _lightAnimation.value,
            waveAnimation: _waveAnimation.value,
            isDarkMode: widget.isDarkMode,
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
          ),
          size: Size(widget.screenWidth, widget.screenHeight),
        );
      },
    );
  }
}

class DynamicBackgroundPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double gradientAnimation;
  final double lightAnimation;
  final double waveAnimation;
  final bool isDarkMode;
  final double screenWidth;
  final double screenHeight;

  DynamicBackgroundPainter({
    required this.gradientColors,
    required this.gradientAnimation,
    required this.lightAnimation,
    required this.waveAnimation,
    required this.isDarkMode,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Main gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
      stops: [
        0.0,
        0.5 + 0.2 * sin(gradientAnimation * 2 * pi),
        1.0,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add dynamic lighting effects
    _drawLightEffects(canvas, size);

    // Add wave patterns
    _drawWavePatterns(canvas, size);

    // Add subtle noise texture
    _drawNoiseTexture(canvas, size);
  }

  void _drawLightEffects(Canvas canvas, Size size) {
    // Create multiple light sources
    final lightPositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.1),
    ];

    for (int i = 0; i < lightPositions.length; i++) {
      final position = lightPositions[i];
      final intensity = 0.3 + 0.2 * sin(lightAnimation * 2 * pi + i);

      canvas.drawCircle(
        position,
        100 + 50 * intensity,
        Paint()..color = Colors.white.withOpacity(0.05 * intensity),
      );
    }
  }

  void _drawWavePatterns(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw multiple wave layers
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final amplitude = 20 + layer * 10;
      final frequency = 0.01 + layer * 0.005;
      final phase = waveAnimation * 2 * pi + layer * pi / 3;

      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height * 0.3 +
            layer * size.height * 0.2 +
            amplitude * sin(x * frequency + phase);

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawNoiseTexture(Canvas canvas, Size size) {
    final noisePaint = Paint()..color = Colors.white.withOpacity(0.02);

    final random = Random(42); // Fixed seed for consistent noise
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
