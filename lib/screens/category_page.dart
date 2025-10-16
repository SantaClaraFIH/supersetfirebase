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
import '../widgets/hover_effects.dart';
import '../utils/logout_util.dart';

import 'all_maths_page.dart';
import 'kids_page.dart';
import 'teens_page.dart';

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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start animation after the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_controller.isAnimating) {
        _controller.repeat();
      }
    });
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.cardBackground.withOpacity(0.1),
                    colors.cardBackground.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.7, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colors.floatingElements[0].withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.cardBackground.withOpacity(0.8),
                        colors.cardBackground.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colors.floatingElements[0].withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: colors.floatingElements[0].withOpacity(0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Premium logo and branding
                      Row(
                        children: [
                          // Premium logo with glow effect
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.floatingElements[0],
                                  colors.floatingElements[1],
                                  colors.floatingElements[2],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.floatingElements[0]
                                      .withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: colors.floatingElements[1]
                                      .withOpacity(0.2),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/spiderman.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          // Premium typography
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Math World',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primaryText,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color:
                                          colors.primaryText.withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2),
                            ],
                          ),
                        ],
                      ),

                      // Right side: Premium controls
                      Row(
                        children: [
                          // Premium PIN badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.9),
                                  Colors.deepOrange.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.security_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'PIN: $pin',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Theme toggle
                          FloatingThemeToggle(),
                          SizedBox(width: 16),
                          // Logout button
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.9),
                                  Colors.redAccent.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => logout(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            toolbarHeight: 140,
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

              // Main content with proper scrollable layout
              SafeArea(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 100, // Account for app bar
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reduced spacing to move tiles up
                          SizedBox(height: screenHeight * 0.05),

                          // Responsive Category Cards
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 800;
                              final cardSpacing = isMobile ? 16.0 : 20.0;

                              return Column(
                                children: [
                                  // Responsive grid layout for all screen sizes
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final screenWidth = constraints.maxWidth;
                                      final crossAxisCount = screenWidth < 600
                                          ? 1
                                          : screenWidth < 900
                                              ? 2
                                              : 3;
                                      final childAspectRatio =
                                          screenWidth < 600 ? 1.0 : 0.8;

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: childAspectRatio,
                                          crossAxisSpacing: cardSpacing,
                                          mainAxisSpacing: cardSpacing,
                                        ),
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final cat = categories[index];
                                          final subtitle =
                                              _subtitleFor(cat.title);

                                          return HoverCard(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => cat.page),
                                            ),
                                            hoverScale: 1.05,
                                            hoverElevation: 20.0,
                                            hoverGlowColor:
                                                colors.floatingElements[2],
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    colors.cardBackground
                                                        .withOpacity(0.85),
                                                    colors.cardBackground
                                                        .withOpacity(0.95),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: colors
                                                      .floatingElements[2],
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  // Image section - Full width
                                                  Expanded(
                                                    flex: 3,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(14),
                                                        topRight:
                                                            Radius.circular(14),
                                                      ),
                                                      child: Image.asset(
                                                        cat.assetPath,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                  // Content section - Below image
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              cat.title,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenWidth <
                                                                            600
                                                                        ? 16
                                                                        : 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: colors
                                                                    .accentText,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Flexible(
                                                            child: Text(
                                                              subtitle,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenWidth <
                                                                            600
                                                                        ? 12
                                                                        : 14,
                                                                color: colors
                                                                    .secondaryText,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                          // Bottom spacing
                          SizedBox(height: screenHeight * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
