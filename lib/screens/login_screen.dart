import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'package:supersetfirebase/provider/theme_provider.dart';
import 'package:supersetfirebase/config/app_theme.dart';
import 'package:supersetfirebase/widgets/theme_toggle_button.dart';
import 'package:supersetfirebase/widgets/particle_system.dart';
import 'package:supersetfirebase/widgets/dynamic_background.dart';
import 'package:supersetfirebase/widgets/glassmorphic_card.dart';
import 'package:supersetfirebase/widgets/hover_effects.dart';
import 'package:supersetfirebase/screens/category_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(3, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(3, (_) => FocusNode());

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start animation after the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bounceController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });

    String pin = _controllers.map((c) => c.text).join();

    if (pin.length != 3) {
      setState(() {
        _errorMessage = 'Please enter all 3 numbers!';
      });
      for (int i = 0; i < 3; i++) {
        if (_controllers[i].text.isEmpty) {
          _focusNodes[i].requestFocus();
          break;
        }
      }
      return;
    }

    if (!RegExp(r'^\d{3}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must contain only numbers!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final pinDoc = await FirebaseFirestore.instance
          .collection('pins')
          .where('pin', isEqualTo: pin)
          .get();

      if (pinDoc.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Oops! Wrong PIN. Try again!';
          _isLoading = false;
        });
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        return;
      }

      Provider.of<UserPinProvider>(context, listen: false).setPin(pin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Welcome back!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CategoryPage(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Connection error. Please check your internet and try again!';
        _isLoading = false;
      });

      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Clean modern background with subtle texture
          _buildModernBackground(screenWidth, screenHeight),

          // Particle system is now integrated into the background

          // Theme toggle button in top-right corner
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingThemeToggle(),
          ),

          // Main content area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: _buildMainContent(
                    context, screenWidth, screenHeight, isMobile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBackground(double screenWidth, double screenHeight) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return Stack(
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
            // Subtle grid pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: GridPatternPainter(colors.gridColor),
              ),
            ),
            // Soft geometric shapes
            ..._buildGeometricShapes(screenWidth, screenHeight, colors),
          ],
        );
      },
    );
  }

  List<Widget> _buildGeometricShapes(
      double screenWidth, double screenHeight, AppColorScheme colors) {
    return [
      // Soft circles in background
      Positioned(
        right: screenWidth * 0.1,
        top: screenHeight * 0.2,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors.geometricShape1,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        left: screenWidth * 0.1,
        bottom: screenHeight * 0.2,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.geometricShape2,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  Widget _buildMainContent(BuildContext context, double screenWidth,
      double screenHeight, bool isMobile) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return GlassmorphicCard(
          isDarkMode: themeProvider.isDarkMode,
          width: isMobile ? screenWidth * 0.9 : 500,
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.6,
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 32 : 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: CircleAvatar(
                          radius: isMobile ? 50 : 60,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: CircleAvatar(
                            radius: isMobile ? 45 : 55,
                            backgroundImage:
                                AssetImage('assets/images/spiderman.png'),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 16 : 24),

                  // Title
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: Text(
                          '🎮 Let\'s Play & Learn! 🎮',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                            shadows: [
                              Shadow(
                                color: colors.primaryText.withOpacity(0.1),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 24 : 32),

                  // PIN Input Container
                  Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 28),
                    decoration: BoxDecoration(
                      color: colors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.inputBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Enter your secret code!',
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28,
                            color: colors.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isMobile ? 24 : 32),

                        // PIN boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final boxSize = isMobile ? 60.0 : 70.0;
                            return Container(
                              width: boxSize,
                              height: boxSize,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 8),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 26,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                                textInputAction: index < 2
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: colors.floatingElements[index]
                                      .withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colors.floatingElements[index]
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colors.floatingElements[index]
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colors.floatingElements[index],
                                      width: 3,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 2) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                                onSubmitted: (value) {
                                  if (index == 2) {
                                    _login();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: isMobile ? 20 : 24),

                        // Error message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: isMobile ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: isMobile ? 24 : 32),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: HoverButton(
                            onPressed: _isLoading ? null : _login,
                            hoverScale: 1.05,
                            hoverElevation: 16.0,
                            hoverColor: colors.primaryButton.withOpacity(0.9),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primaryButton,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: isMobile ? 16 : 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: colors.primaryButtonShadow,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: isMobile ? 20 : 24,
                                    width: isMobile ? 20 : 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Let\'s Go!',
                                        style: TextStyle(
                                          fontSize: isMobile ? 18 : 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        Icons.rocket_launch,
                                        color: Colors.white,
                                        size: isMobile ? 20 : 24,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        SizedBox(height: isMobile ? 20 : 24),

                        // Signup button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SignupScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create New Secret Code',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: colors.accentText,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: colors.accentText,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.emoji_events,
                                color: colors.accentText,
                                size: isMobile ? 18 : 20,
                              ),
                            ],
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
      },
    );
  }
}

// Custom painter for subtle grid pattern
class GridPatternPainter extends CustomPainter {
  final Color gridColor;

  GridPatternPainter(this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for modern puzzle pieces
class PuzzlePiecePainter extends CustomPainter {
  final Color color;

  PuzzlePiecePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2.5;

    // Draw a simple geometric shape instead of complex puzzle piece
    final path = Path();

    // Create a rounded square with small notches
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: radius * 2,
        height: radius * 2,
      ),
      Radius.circular(8),
    );

    path.addRRect(rect);

    // Add small decorative circles
    canvas.drawCircle(
      Offset(centerX + radius * 0.6, centerY),
      radius * 0.15,
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(centerX - radius * 0.6, centerY),
      radius * 0.15,
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(centerX, centerY + radius * 0.6),
      radius * 0.15,
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(centerX, centerY - radius * 0.6),
      radius * 0.15,
      Paint()..color = color.withOpacity(0.3),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
