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
import '../gamescreen/mathequations/main.dart' show MathEquationsApp;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        // Game cards data
        final games = [
          {
            'title': 'Equations',
            'subtitle': 'Master equations!',
            'image': 'assets/images/math_equations.png',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MathEquationsApp(),
                ),
              );
            },
          },
          {
            'title': 'Geometry',
            'subtitle': 'Learn shapes & angles!',
            'image': 'assets/images/math_geometry.png',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BilingualMathGeo(),
                ),
              );
            },
          },
          {
            'title': 'Decimals',
            'subtitle': 'Work with decimals!',
            'image': 'assets/images/decimals.png',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DecimalApp(),
                ),
              );
            },
          },
          {
            'title': 'NumQuest',
            'subtitle': 'Fun number challenges!',
            'image': 'assets/images/math_numquest.png',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NumQuestPage(),
                ),
              );
            },
          },
        ];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TopBar(
            title: 'Teens',
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
