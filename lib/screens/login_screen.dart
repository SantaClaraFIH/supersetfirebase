import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'package:supersetfirebase/screens/category_page.dart';
import 'dart:math';

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

  final List<Color> _pinBoxColors = [
    Color(0xFFFF6B9D), // Soft pink
    Color(0xFF6BCF7F), // Mint green
    Color(0xFF4D96FF), // Soft blue
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
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

          // Playful puzzle pieces floating around
          ..._buildFloatingPuzzlePieces(screenWidth, screenHeight),

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC), // Very light blue-gray
            Color(0xFFF1F5F9), // Light gray
            Color(0xFFE2E8F0), // Slightly darker gray
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(),
            ),
          ),
          // Soft geometric shapes
          ..._buildGeometricShapes(screenWidth, screenHeight),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingPuzzlePieces(
      double screenWidth, double screenHeight) {
    final puzzlePieces = <Widget>[];

    // Strategic positions around the edges, not interfering with content
    final positions = [
      Offset(0.05 * screenWidth, 0.1 * screenHeight),
      Offset(0.9 * screenWidth, 0.08 * screenHeight),
      Offset(0.02 * screenWidth, 0.25 * screenHeight),
      Offset(0.93 * screenWidth, 0.3 * screenHeight),
      Offset(0.08 * screenWidth, 0.75 * screenHeight),
      Offset(0.88 * screenWidth, 0.8 * screenHeight),
      Offset(0.03 * screenWidth, 0.9 * screenHeight),
      Offset(0.92 * screenWidth, 0.6 * screenHeight),
    ];

    // Soft, playful colors that complement the modern palette
    final colors = [
      Color(0xFFFF6B9D), // Soft pink
      Color(0xFFFFD93D), // Warm yellow
      Color(0xFF6BCF7F), // Mint green
      Color(0xFF4D96FF), // Soft blue
      Color(0xFFFF8A65), // Coral
      Color(0xFF9C88FF), // Lavender
      Color(0xFFFFB74D), // Peach
      Color(0xFF4DD0E1), // Sky blue
    ];

    for (int i = 0; i < positions.length; i++) {
      puzzlePieces.add(
        Positioned(
          left: positions[i].dx,
          top: positions[i].dy,
          child: AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  5 * sin(_bounceController.value * 2 * pi + i),
                  3 * cos(_bounceController.value * 2 * pi + i),
                ),
                child: Transform.rotate(
                  angle: (i * 0.3) % (2 * pi) +
                      0.1 * sin(_bounceController.value * 2 * pi + i),
                  child: Container(
                    width: 32 + (i % 3) * 8,
                    height: 32 + (i % 3) * 8,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length].withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors[i % colors.length].withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: PuzzlePiecePainter(colors[i % colors.length]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return puzzlePieces;
  }

  List<Widget> _buildGeometricShapes(double screenWidth, double screenHeight) {
    return [
      // Soft circles in background
      Positioned(
        right: screenWidth * 0.1,
        top: screenHeight * 0.2,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF).withOpacity(0.05),
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
            color: Color(0xFFFF6B9D).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  Widget _buildMainContent(BuildContext context, double screenWidth,
      double screenHeight, bool isMobile) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? screenWidth * 0.9 : 500,
        minHeight: screenHeight * 0.6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
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
                        color: Color(0xFF1E293B),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
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
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Enter your secret code!',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        color: Color(0xFF1E293B),
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
                              color: Color(0xFF1E293B),
                            ),
                            textInputAction: index < 2
                                ? TextInputAction.next
                                : TextInputAction.done,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: _pinBoxColors[index].withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: _pinBoxColors[index].withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: _pinBoxColors[index].withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: _pinBoxColors[index],
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: isMobile ? 16 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Color(0xFF6C63FF).withOpacity(0.4),
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
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF6C63FF),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.emoji_events,
                            color: Color(0xFF6C63FF),
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
  }
}

// Custom painter for subtle grid pattern
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFE2E8F0).withOpacity(0.3)
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
