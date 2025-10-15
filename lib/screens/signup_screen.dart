import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/theme_provider.dart';
import 'package:supersetfirebase/config/app_theme.dart';
import 'package:supersetfirebase/widgets/theme_toggle_button.dart';
import 'package:supersetfirebase/widgets/particle_system.dart';
import 'package:supersetfirebase/widgets/dynamic_background.dart';
import 'package:supersetfirebase/widgets/glassmorphic_card.dart';
import 'package:supersetfirebase/widgets/hover_effects.dart';
import 'package:supersetfirebase/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
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

  Future<void> _signup() async {
    final pin = _controllers.map((controller) => controller.text).join();

    if (pin.length != 3) {
      setState(() {
        _errorMessage = 'Oops! We need all 3 numbers for your secret code! 🎯';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final existingPin = await FirebaseFirestore.instance
          .collection('pins')
          .where('pin', isEqualTo: pin)
          .get();

      if (existingPin.docs.isNotEmpty) {
        setState(() {
          _errorMessage =
              'This secret code is already taken! Try another one! 🎲';
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('pins').add({
        'pin': pin,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Oopsie! Something went wrong. Let\'s try again! 🌟';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingThemeToggle(),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
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

              // Main content
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
      },
    );
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
                          '🎯 Create Your Secret Code! 🎯',
                          style: TextStyle(
                            fontSize: isMobile
                                ? 18
                                : (screenWidth < 600
                                    ? 20
                                    : screenWidth < 800
                                        ? 22
                                        : 24),
                            color: colors.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        Text(
                          'Choose 3 numbers for your secret code:',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: colors.secondaryText,
                            fontWeight: FontWeight.w500,
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
                                    _signup();
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

                        SizedBox(height: isMobile ? 20 : 24),

                        // Create button
                        SizedBox(
                          width: double.infinity,
                          child: HoverButton(
                            onPressed: _isLoading ? null : _signup,
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
                                        'Create My Code!',
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

                        SizedBox(height: isMobile ? 16 : 20),

                        // Back to login
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.login,
                                size: 16,
                                color: colors.accentText,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Already have a code? Sign In',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.accentText,
                                  fontWeight: FontWeight.w500,
                                ),
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
