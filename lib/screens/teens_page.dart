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
import '../gamescreen/mathequations/main.dart' show MathEquationsApp;
import '../screens/category_page.dart';
import '../gamescreen/mathgeometry/main.dart' show BilingualMathGeo;
import '../gamescreen/mathdecimals/main.dart' show DecimalApp;
import '../gamescreen/mathnumquest/main.dart' show NumQuestPage;

class TeensPage extends StatefulWidget {
  const TeensPage({Key? key}) : super(key: key);

  @override
  State<TeensPage> createState() => _TeensPageState();
}

class _TeensPageState extends State<TeensPage>
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

    // Responsive card dimensions
    final double cardWidth = min(screenWidth * 0.4, 220);
    final double cardHeight = cardWidth * 1.1;

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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryPage()),
                );
              },
            ),
            title: Text(
              'Teens',
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
                    _PinBadge(pin: pin, colors: colors),
                    SizedBox(height: screenHeight * 0.05),

                    // Cards section
                    Expanded(
                      child: Center(
                        child: Wrap(
                          spacing: screenWidth * 0.05,
                          runSpacing: screenHeight * 0.04,
                          alignment: WrapAlignment.center,
                          children: [
                            _GameCard(
                              width: cardWidth,
                              height: cardHeight,
                              image: 'assets/images/math_equations.png',
                              icon: Icons.functions,
                              iconColor: Colors.purple,
                              title: 'Equations',
                              description: 'Master equations!',
                              colors: colors,
                              isDarkMode: themeProvider.isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MathEquationsApp(),
                                  ),
                                );
                              },
                            ),
                            _GameCard(
                              width: cardWidth,
                              height: cardHeight,
                              image: 'assets/images/math_geometry.png',
                              icon: Icons.square_foot,
                              iconColor: Colors.teal,
                              title: 'Geometry',
                              description: 'Learn shapes & angles!',
                              colors: colors,
                              isDarkMode: themeProvider.isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BilingualMathGeo(),
                                  ),
                                );
                              },
                            ),
                            _GameCard(
                              width: cardWidth,
                              height: cardHeight,
                              image: 'assets/images/decimals.png',
                              icon: Icons.calculate,
                              iconColor: Colors.indigo,
                              title: 'Decimals',
                              description: 'Work with decimals!',
                              colors: colors,
                              isDarkMode: themeProvider.isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DecimalApp(),
                                  ),
                                );
                              },
                            ),
                            _GameCard(
                              width: cardWidth,
                              height: cardHeight,
                              image: 'assets/images/math_numquest.png',
                              icon: Icons.quiz,
                              iconColor: Colors.deepOrange,
                              title: 'NumQuest',
                              description: 'Fun number challenges!',
                              colors: colors,
                              isDarkMode: themeProvider.isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NumQuestPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _GameCard extends StatelessWidget {
  final double width;
  final double height;
  final String image;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final AppColorScheme colors;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _GameCard({
    required this.width,
    required this.height,
    required this.image,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.colors,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      hoverScale: 1.05,
      hoverElevation: 16.0,
      hoverGlowColor: iconColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: height + 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image fills the card
            GlassmorphicCard(
              isDarkMode: isDarkMode,
              borderRadius: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.accentText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
