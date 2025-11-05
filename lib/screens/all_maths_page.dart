import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../config/app_theme.dart';
import '../widgets/particle_system.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/game_card.dart';
import '../widgets/card_grid.dart';
import '../gamescreen/mathmingle/main.dart' show MathMingleApp;

class AllMathsPage extends StatefulWidget {
  const AllMathsPage({Key? key}) : super(key: key);

  @override
  State<AllMathsPage> createState() => _AllMathsPageState();
}

class _AllMathsPageState extends State<AllMathsPage>
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        // Game cards data
        final games = [
          {
            'title': 'Math Mingle',
            'subtitle': 'Fun with numbers!',
            'image': 'assets/images/math_mingle.png',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MathMingleApp(),
                ),
              );
            },
          },
        ];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TopBar(
            title: 'All Maths',
            showBackButton: true,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: CardGrid(
                    children: games.map((game) {
                      return GameCard(
                        title: game['title'] as String,
                        subtitle: game['subtitle'] as String,
                        imageSrc: game['image'] as String,
                        onClick: game['onTap'] as VoidCallback,
                        colors: colors,
                        isDarkMode: themeProvider.isDarkMode,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
