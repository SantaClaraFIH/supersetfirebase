import 'package:flutter/material.dart';
import 'dart:math';

class ParticleSystem extends StatefulWidget {
  final bool isDarkMode;
  final List<Color> colors;
  final double screenWidth;
  final double screenHeight;

  const ParticleSystem({
    super.key,
    required this.isDarkMode,
    required this.colors,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _initializeParticles();
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < 35; i++) {
      final particleType =
          ParticleType.values[_random.nextInt(ParticleType.values.length)];
      final baseSize = _random.nextDouble() * 8 + 4;

      // Make text and equation particles bigger for better readability
      final size = (particleType == ParticleType.text ||
              particleType == ParticleType.equation)
          ? baseSize * 1.5 // 50% bigger for text particles
          : baseSize;

      _particles.add(Particle(
        x: _random.nextDouble() * widget.screenWidth,
        y: _random.nextDouble() * widget.screenHeight,
        vx: (_random.nextDouble() - 0.5) * 0.5,
        vy: (_random.nextDouble() - 0.5) * 0.5,
        size: size,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        opacity: _random.nextDouble() * 0.8 + 0.2,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
        particleType: particleType,
        text: _getRandomMathContent(),
      ));
    }
  }

  String _getRandomMathContent() {
    final mathNumbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    final mathOperators = [
      '+',
      '-',
      '×',
      '÷',
      '%',
      '=',
      'π',
      '√',
      '∞',
      '∑',
      '∫',
      '∂',
      '∇',
      '±',
      '≈',
      '≠',
      '≤',
      '≥',
      '<',
      '>'
    ];
    final mathSymbols = [
      'α',
      'β',
      'γ',
      'δ',
      'θ',
      'λ',
      'μ',
      'σ',
      'φ',
      'ψ',
      'ω',
      'Ω',
      'Δ',
      'Γ',
      'Λ',
      'Φ',
      'Ψ',
      'Σ',
      'Π',
      'Θ'
    ];
    final fractions = [
      '½',
      '⅓',
      '⅔',
      '¼',
      '¾',
      '⅕',
      '⅖',
      '⅗',
      '⅘',
      '⅙',
      '⅚',
      '⅛',
      '⅜',
      '⅝',
      '⅞'
    ];
    final equations = [
      'x²',
      'y³',
      'z⁴',
      'a²',
      'b²',
      'c²',
      'x₁',
      'x₂',
      'y₁',
      'y₂'
    ];

    final allContent = [
      ...mathNumbers,
      ...mathOperators,
      ...mathSymbols,
      ...fractions,
      ...equations
    ];
    return allContent[_random.nextInt(allContent.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_particleController, _pulseController, _rotationController]),
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            pulseAnimation: _pulseController.value,
            rotationAnimation: _rotationController.value,
            isDarkMode: widget.isDarkMode,
          ),
          size: Size(widget.screenWidth, widget.screenHeight),
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.rotation += particle.rotationSpeed;

      // Wrap around screen
      if (particle.x < 0) particle.x = widget.screenWidth;
      if (particle.x > widget.screenWidth) particle.x = 0;
      if (particle.y < 0) particle.y = widget.screenHeight;
      if (particle.y > widget.screenHeight) particle.y = 0;
    }
  }
}

enum ParticleType {
  star,
  hexagon,
  circle,
  triangle,
  diamond,
  pentagon,
  octagon,
  text,
  equation,
}

class Particle {
  double x, y, vx, vy, size, opacity, rotation, rotationSpeed;
  Color color;
  ParticleType particleType;
  String text;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.particleType,
    required this.text,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double pulseAnimation;
  final double rotationAnimation;
  final bool isDarkMode;

  ParticlePainter({
    required this.particles,
    required this.pulseAnimation,
    required this.rotationAnimation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
            .withOpacity(particle.opacity * (0.5 + pulseAnimation * 0.5))
        ..style = PaintingStyle.fill;

      // Create glowing effect with different intensities based on particle type
      final glowIntensity = particle.particleType == ParticleType.text ||
              particle.particleType == ParticleType.equation
          ? 0.7 // Stronger glow for text particles
          : 0.3;

      final glowPaint = Paint()
        ..color = particle.color
            .withOpacity(particle.opacity * glowIntensity * pulseAnimation)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 12); // Bigger blur for text

      // Draw glow - bigger for text particles
      final glowSize = (particle.particleType == ParticleType.text ||
              particle.particleType == ParticleType.equation)
          ? particle.size * 3 // Bigger glow for text
          : particle.size * 2;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        glowSize,
        glowPaint,
      );

      // Draw main particle
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation + rotationAnimation * 0.1);

      // Draw different shapes based on particle type
      switch (particle.particleType) {
        case ParticleType.star:
          _drawStar(canvas, paint, particle.size);
          break;
        case ParticleType.hexagon:
          _drawHexagon(canvas, paint, particle.size);
          break;
        case ParticleType.triangle:
          _drawTriangle(canvas, paint, particle.size);
          break;
        case ParticleType.diamond:
          _drawDiamond(canvas, paint, particle.size);
          break;
        case ParticleType.pentagon:
          _drawPentagon(canvas, paint, particle.size);
          break;
        case ParticleType.octagon:
          _drawOctagon(canvas, paint, particle.size);
          break;
        case ParticleType.text:
          _drawText(canvas, paint, particle.text, particle.size);
          break;
        case ParticleType.equation:
          _drawEquation(canvas, paint, particle.text, particle.size);
          break;
        case ParticleType.circle:
          // Circle with inner pattern
          canvas.drawCircle(Offset.zero, particle.size, paint);
          canvas.drawCircle(Offset.zero, particle.size * 0.5,
              Paint()..color = particle.color.withOpacity(0.3));
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final outerX = cos(angle) * outerRadius;
      final outerY = sin(angle) * outerRadius;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerAngle = ((i + 0.5) * 2 * pi / 5) - pi / 2;
      final innerX = cos(innerAngle) * innerRadius;
      final innerY = sin(innerAngle) * innerRadius;
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3);
      final x = cos(angle) * size;
      final y = sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * pi / 3) - pi / 2;
      final x = cos(angle) * size;
      final y = sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final points = [
      Offset(0, -size), // Top
      Offset(size, 0), // Right
      Offset(0, size), // Bottom
      Offset(-size, 0), // Left
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPentagon(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final x = cos(angle) * size;
      final y = sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawOctagon(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final x = cos(angle) * size;
      final y = sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, Paint paint, String text, double size) {
    // Draw text directly without any background shape
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: paint.color,
          fontSize: size * 1.5, // Make text bigger and more readable
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawEquation(Canvas canvas, Paint paint, String text, double size) {
    // Draw equation text directly without any background shape
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: paint.color,
          fontSize: size * 1.3, // Make text bigger and more readable
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
