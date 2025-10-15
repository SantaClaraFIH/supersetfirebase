import 'package:flutter/material.dart';

class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final bool isDarkMode;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius = 24,
    this.boxShadow,
    this.border,
    required this.isDarkMode,
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ]
                  : [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.4),
                    ],
            ),
            border: widget.border ??
                Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
            boxShadow: widget.boxShadow ??
                [
                  BoxShadow(
                    color: widget.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.1 * _glowAnimation.value)
                        : Colors.blue.withOpacity(0.1 * _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                // Shimmer effect
                Positioned.fill(
                  child: CustomPaint(
                    painter: ShimmerPainter(
                      animation: _shimmerAnimation.value,
                      isDarkMode: widget.isDarkMode,
                    ),
                  ),
                ),
                // Content
                Container(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;

  ShimmerPainter({
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ]
            : [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
        stops: [
          0.0,
          0.5 + animation * 0.5,
          1.0,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced floating action button with glassmorphism
class GlassmorphicFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final bool isDarkMode;

  const GlassmorphicFAB({
    super.key,
    this.onPressed,
    this.child,
    this.backgroundColor,
    required this.isDarkMode,
  });

  @override
  State<GlassmorphicFAB> createState() => _GlassmorphicFABState();
}

class _GlassmorphicFABState extends State<GlassmorphicFAB>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [
                  Colors.red.withOpacity(0.8),
                  Colors.redAccent.withOpacity(0.6),
                ]
              : [
                  Colors.red.withOpacity(0.9),
                  Colors.redAccent.withOpacity(0.7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: widget.child ??
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
