// lib/screens/kids_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_pin_provider.dart';
import '../provider/theme_provider.dart';
import '../config/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/particle_system.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/hover_effects.dart';
import '../utils/logout_util.dart';
import '../gamescreen/mathoperations/main.dart' show Operators;
import '../gamescreen/mathcountingandsequence/main.dart' show MyApp;

class KidsPage extends StatefulWidget {
  const KidsPage({Key? key}) : super(key: key);

  @override
  State<KidsPage> createState() => _KidsPageState();
}

class _KidsPageState extends State<KidsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pin = Provider.of<UserPinProvider>(context, listen: false).pin;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Game cards data
    final games = [
      {
        'title': 'Operators',
        'subtitle': 'Learn new symbols & more!',
        'image': 'assets/images/math_operators.png',
        'icon': Icons.show_chart,
        'color': Colors.green,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Operators(userPin: pin)),
            ),
      },
      {
        'title': 'Counting & Sequence',
        'subtitle': 'Learn numbers & order!',
        'image': 'assets/images/math_countseq.png',
        'icon': Icons.format_list_numbered,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyApp()),
            ),
      },
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primaryText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Kids',
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingThemeToggle(),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Dynamic gradient background
              DynamicBackground(
                isDarkMode: themeProvider.isDarkMode,
                gradientColors: colors.backgroundGradient,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              // Particle system
              ParticleSystem(
                isDarkMode: themeProvider.isDarkMode,
                colors: colors.floatingElements,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.cardBackground.withOpacity(
                              0.3 + 0.2 * sin(_controller.value * 2 * pi)),
                          colors.cardBackground.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Centered PIN badge
                    Center(child: _PinBadge(pin: pin, colors: colors)),

                    SizedBox(height: screenHeight * 0.05),

                    // Centered game cards
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: games.map((game) {
                              double cardWidth = min(screenWidth * 0.7, 300);
                              double cardHeight = screenHeight * 0.55;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: HoverCard(
                                  onTap: game['onTap'] as VoidCallback,
                                  hoverScale: 1.05,
                                  hoverElevation: 16.0,
                                  hoverGlowColor: game['color'] as Color,
                                  child: SizedBox(
                                    width: cardWidth,
                                    height: cardHeight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image card
                                        Expanded(
                                          flex: 7,
                                          child: GlassmorphicCard(
                                            isDarkMode:
                                                themeProvider.isDarkMode,
                                            borderRadius: 16,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.asset(
                                                game['image'] as String,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // Content BELOW the image
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    game['icon'] as IconData,
                                                    size: 28,
                                                    color:
                                                        game['color'] as Color,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    game['title'] as String,
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colors.accentText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                game['subtitle'] as String,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: colors.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: GlassmorphicFAB(
            isDarkMode: themeProvider.isDarkMode,
            onPressed: () => logout(context),
            child: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        );
      },
    );
  }
}

// Theme-aware PIN badge
class _PinBadge extends StatelessWidget {
  final String pin;
  final AppColorScheme colors;

  const _PinBadge({required this.pin, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.floatingElements.take(2).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        'PIN: $pin',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
