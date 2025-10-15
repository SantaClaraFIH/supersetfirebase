import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/category.dart';
import '../provider/user_pin_provider.dart';
import '../provider/theme_provider.dart';
import '../config/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/particle_system.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/hover_effects.dart';
import '../utils/logout_util.dart';

import 'all_maths_page.dart';
import 'kids_page.dart';
import 'teens_page.dart';
import '../screens/login_screen.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
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

  String _subtitleFor(String title) {
    switch (title) {
      case 'All Maths':
        return '(For all ages)';
      case 'Kids':
        return '(Ages: 5 to 12)';
      case 'Teens':
        return '(Age: 13+)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = Provider.of<UserPinProvider>(context, listen: false).pin;

    final categories = <Category>[
      Category(
        title: 'All Maths',
        assetPath: 'assets/images/all_maths_tile.png',
        page: const AllMathsPage(),
      ),
      Category(
        title: 'Kids',
        assetPath: 'assets/images/kids_tile.png',
        page: const KidsPage(),
      ),
      Category(
        title: 'Teens',
        assetPath: 'assets/images/teens_tile.png',
        page: const TeensPage(),
      ),
    ];

    // Sort categories by age
    categories.sort((a, b) {
      int ageOrder(String title) {
        switch (title) {
          case 'Kids':
            return 1;
          case 'Teens':
            return 2;
          case 'All Maths':
            return 3;
          default:
            return 99;
        }
      }

      return ageOrder(a.title).compareTo(ageOrder(b.title));
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              "Welcome to Math World",
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: colors.primaryText.withOpacity(0.3),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
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
              // Floating symbols
              ..._buildFloatingSymbols(screenWidth, screenHeight, colors),
              // Main content
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PIN badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.008),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.floatingElements[0],
                            colors.floatingElements[1],
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadow,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'PIN: $pin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categories.map((cat) {
                          final subtitle = _subtitleFor(cat.title);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: HoverCard(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => cat.page),
                                ),
                                hoverScale: 1.03,
                                hoverElevation: 12.0,
                                hoverGlowColor: colors.floatingElements[2],
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.cardBackground.withOpacity(0.85),
                                        colors.cardBackground.withOpacity(0.95),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colors.floatingElements[2],
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.asset(
                                            cat.assetPath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colors.accentText,
                                          shadows: [
                                            Shadow(
                                              color: colors.cardShadow,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.secondaryText,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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

  List<Widget> _buildFloatingSymbols(
      double width, double height, AppColorScheme colors) {
    List<Widget> symbols = [];
    for (int i = 0; i < 6; i++) {
      symbols.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double top = (height * 0.1 +
                    i * 50 +
                    20 * sin(_controller.value * 2 * pi + i)) %
                height;
            double left = (width * 0.1 +
                    i * 60 +
                    30 * cos(_controller.value * 2 * pi + i)) %
                width;
            return Positioned(
              top: top,
              left: left,
              child: Icon(
                i % 2 == 0 ? Icons.star : Icons.circle,
                color: colors
                    .floatingElements[i % colors.floatingElements.length]
                    .withOpacity(0.6),
                size: 40,
              ),
            );
          },
        ),
      );
    }
    return symbols;
  }
}
