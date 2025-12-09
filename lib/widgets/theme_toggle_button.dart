import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/theme_provider.dart';
import 'dart:math';

class ThemeToggleButton extends StatefulWidget {
  final double? size;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? iconColor;

  const ThemeToggleButton({
    super.key,
    this.size,
    this.padding,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
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
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: () async {
            _rotationController.forward().then((_) {
              _rotationController.reset();
            });
            await themeProvider.toggleTheme();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_rotationAnimation, _scaleAnimation, _glowAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.orange
                                .withOpacity(0.3 * _glowAnimation.value)
                            : Colors.blue
                                .withOpacity(0.3 * _glowAnimation.value),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: themeProvider.isDarkMode
                            ? [
                                const Color(0xFFFF6B35),
                                const Color(0xFFF7931E),
                              ]
                            : [
                                const Color(0xFF4A90E2),
                                const Color(0xFF357ABD),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          _rotationController.forward().then((_) {
                            _rotationController.reset();
                          });
                          await themeProvider.toggleTheme();
                        },
                        child: Container(
                          padding: widget.padding ?? const EdgeInsets.all(12),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.wb_sunny
                                  : Icons.nightlight_round,
                              size: widget.size ?? 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Enhanced floating theme toggle for app bars
class FloatingThemeToggle extends StatefulWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const FloatingThemeToggle({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  State<FloatingThemeToggle> createState() => _FloatingThemeToggleState();
}

class _FloatingThemeToggleState extends State<FloatingThemeToggle>
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeProvider.isDarkMode
                    ? Colors.orange.withOpacity(0.4)
                    : Colors.blue.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? [
                        const Color(0xFFFF6B35).withOpacity(0.9),
                        const Color(0xFFF7931E).withOpacity(0.9),
                      ]
                    : [
                        const Color(0xFF4A90E2).withOpacity(0.9),
                        const Color(0xFF357ABD).withOpacity(0.9),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ThemeToggleButton(
              size: widget.size ?? 20,
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.transparent,
              iconColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
