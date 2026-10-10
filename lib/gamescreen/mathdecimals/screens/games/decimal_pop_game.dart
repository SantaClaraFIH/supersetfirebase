import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecimalPopGame extends StatefulWidget {
  const DecimalPopGame({super.key});

  @override
  _DecimalPopGameState createState() => _DecimalPopGameState();
}

class _DecimalPopGameState extends State<DecimalPopGame>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.23, 0.67, 0.45, 0.12],
      'answer': 0.67
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.12, 0.09, 0.25, 0.19],
      'answer': 0.25
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.3, 0.31, 0.299, 0.29],
      'answer': 0.31
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.78, 0.87, 0.65, 0.54],
      'answer': 0.87
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.111, 0.11, 0.1, 0.09],
      'answer': 0.111
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.8, 0.88, 0.82, 0.81],
      'answer': 0.88
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.11, 0.8, 0.18, 0.81],
      'answer': 0.81
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [1.5, 1.31, 1.18, 1.42],
      'answer': 1.5
    },
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  int bestScore = 0;
  String feedbackText = "";
  String mascotMessage = "Ask me how to say it!";
  // bool _initialMascotMessageSpoken = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late List<double> shuffledOptions;
  List<AnimationController> _controllers = [];
  late List<Animation<double>> _animations;
  late AnimationController _mascotController;
  late Animation<double> _mascotBounce;

  final Map<String, String> originalTexts = {
    'question': 'Pick the balloon with the greatest value!',
    'title': 'Decimal Pop Game',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;

  Future<void> translateTexts() async {
    if (!translated) {
      try {
        final translations = await TranslationService.translateMap(originalTexts);
        setState(() {
          translatedTexts = translations;
          translated = true;
        });
      } catch (e) {
        debugPrint('Failed to fetch translations: $e');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
    _initAnimations();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );
    _loadBestScore();
    // Speak the inital mascot message
    // if (!_initialMascotMessageSpoken) {
    //   _speakMascot(mascotMessage);
    //   _initialMascotMessageSpoken = true;
    // }
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
  }

  void _speakMascot(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.3);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.speak(message);
  }

  // Add a function to speak the actual decimal
  void _speakQuestionAndOptions() async {
    await _flutterTts.setLanguage("en-US");
    // Speak each option
    String optionsText = "The options are: ";
    for (int i = 0; i < shuffledOptions.length; i++) {
     if (_controllers[i].value < 1.0) {
      optionsText += "${pronounceDecimal(shuffledOptions[i])},  ";
     }
    }
    await _flutterTts.speak(optionsText);
  }

  // This is the helper function that helps TTS to speak the correct decimal
  // placements. For example, instead of 0.23 it should speak 0 and 23 hundredths.
  String pronounceDecimal(double decimal) {
    if (decimal == decimal.toInt()) {
      return decimal.toInt().toString();
    }

    String decimalString = decimal.toString();
    List<String> parts = decimalString.split('.');
    String wholePart = parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : "";
    String pronunciation = "";

    // Pronounce the whole part
    if (wholePart == "0") {
      pronunciation += "zero";
    } else {
      pronunciation += wholePart;
    }

    if (fractionalPart.isNotEmpty) {
      int numDigits = fractionalPart.length;
      String placeValue = "";

      switch (numDigits) {
        case 1:
          placeValue = "tenths";
          break;
        case 2:
          placeValue = "hundredths";
          break;
        case 3:
          placeValue = "thousandths";
          break;
        default:
          // For very long decimals, might just say "point" and the digits
          return "$wholePart point ${fractionalPart.split('').join(' ')}";
      }

      pronunciation += " and ${int.parse(fractionalPart)} $placeValue";
    }

    return pronunciation;
  }

  void _shuffleOptions() {
    final options =
        List<double>.from(questions[currentQuestionIndex]['options']);
    options.shuffle(Random());
    shuffledOptions = options;
  }

  void _initAnimations() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers = List.generate(
        4,
        (index) => AnimationController(
              duration: const Duration(milliseconds: 250),
              lowerBound: 0.0,
              upperBound: 1.0,
              vsync: this,
            ));
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();
  }

  void checkAnswer(double selected) async {
    int index = shuffledOptions.indexOf(selected);
    await _controllers[index].forward(from: 0.0);

    bool isCorrect = selected == questions[currentQuestionIndex]['answer'];
    if (isCorrect) {
      await _audioPlayer.play(AssetSource('MathDecimals/sounds/success.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('MathDecimals/sounds/error.mp3'));
    }

    setState(() {
      feedbackText = isCorrect ? "✅ Correct!" : "❌ Incorrect";
      if (isCorrect) {
        score += 10;
        if (score > bestScore) {
          bestScore = score;
          _saveBestScore();
        }
      }
    });

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            feedbackText = "";
            mascotMessage = "Ask me how to say it!";
            if (currentQuestionIndex < questions.length - 1) {
              currentQuestionIndex++;
              _shuffleOptions();
              _initAnimations();
            } else {
              _showEndDialog();
            }
          });
        }
      });
    }
  }

  void _showEndDialog() {
    String thankYouMessage = "Amazing! You pop all the ballons!";
    _speakMascot(thankYouMessage);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) {
          final size = MediaQuery.of(dialogContext).size;
          final double screenWidth = size.width;
          final double screenHeight = size.height;

          // Scale factor: 1.0 on standard screen (width >= 800, height >= 600), scales down gracefully on small screens
          final double dialogScale = min(
            1.0,
            min(screenWidth / 800.0, screenHeight / 600.0),
          ).clamp(0.65, 1.0);

          final double imageSize = (100.0 * dialogScale).clamp(55.0, 110.0);
          final double titleFontSize = (22.0 * dialogScale).clamp(16.0, 22.0);
          final double messageFontSize =
              (18.0 * dialogScale).clamp(13.0, 18.0);
          final double buttonFontSize = (16.0 * dialogScale).clamp(13.0, 16.0);
          final double cardBorderRadius =
              (18.0 * dialogScale).clamp(12.0, 18.0);
          final double spacing = (12.0 * dialogScale).clamp(6.0, 14.0);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: (32.0 * dialogScale).clamp(12.0, 40.0),
              vertical: (24.0 * dialogScale).clamp(12.0, 24.0),
            ),
            titlePadding: EdgeInsets.only(
              top: (20.0 * dialogScale).clamp(12.0, 20.0),
              left: 16,
              right: 16,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: (24.0 * dialogScale).clamp(14.0, 24.0),
              vertical: spacing,
            ),
            actionsPadding: EdgeInsets.only(
              bottom: (18.0 * dialogScale).clamp(10.0, 18.0),
              left: 16,
              right: 16,
            ),
            title: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '🎈 Thank You!',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (screenWidth * 0.85).clamp(260.0, 420.0),
                maxHeight: screenHeight * 0.65,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/MathDecimals/poppy.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: spacing),
                    Text(
                      thankYouMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: messageFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(
                          horizontal: (20.0 * dialogScale).clamp(12.0, 22.0),
                          vertical: (10.0 * dialogScale).clamp(6.0, 12.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: (14.0 * dialogScale).clamp(8.0, 16.0)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: (20.0 * dialogScale).clamp(12.0, 22.0),
                          vertical: (10.0 * dialogScale).clamp(6.0, 12.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = 0;
                          score = 0;
                          _shuffleOptions();
                          _initAnimations();
                          mascotMessage = "Ask me how to say it!";
                        });
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'Play Again',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }

  String getBalloonAsset(int index) {
    final balloonColors = [
      'assets/MathDecimals/balloon_red.png',
      'assets/MathDecimals/balloon_purple.png',
      'assets/MathDecimals/balloon_green.png',
      'assets/MathDecimals/balloon_yellow.png',
    ];
    return balloonColors[index % balloonColors.length];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _mascotController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 24, color: Colors.white),
              children: [
                const TextSpan(text: "Decimal Pop Game! "),
                TextSpan(
                  text: "Score: $score",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Best Score: $bestScore",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
                IconButton(
                  icon: const Icon(Icons.translate),
                  onPressed: translateTexts,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MathDecimals/decimalpopbg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                final double screenHeight = constraints.maxHeight;

                // Scale factor is 1.0 on standard normal big screen (width >= 1000, height >= 650)
                // Only scales down proportionally when the screen size is reduced.
                final double scale = min(
                  1.0,
                  min(screenWidth / 1000.0, screenHeight / 650.0),
                );

                // Normal big balloon size matches original (size.width * 0.18 on desktop)
                final double baseBalloonSize =
                    (screenWidth * 0.18).clamp(180.0, 240.0);

                // Boost balloon size on smaller screens so elements are larger and easier to tap
                final double smallScreenBoost = (1.0 - scale) * 0.35;
                final double effectiveBalloonScale =
                    (scale + smallScreenBoost).clamp(0.0, 1.0);
                double balloonSize = baseBalloonSize * effectiveBalloonScale;

                // Protect against extreme height reduction or narrow horizontal widths
                if (screenHeight < 650) {
                  final double heightBound = screenHeight * 0.36;
                  if (heightBound < balloonSize) {
                    balloonSize = heightBound;
                  }
                }
                final double maxAllowedForWidth = (screenWidth - 16) / 4.08;
                if (balloonSize > maxAllowedForWidth) {
                  balloonSize = maxAllowedForWidth;
                }
                balloonSize = balloonSize.clamp(72.0, 240.0);

                final double questionFontSize =
                    (28.0 * scale).clamp(16.0, 28.0);
                final double feedbackFontSize =
                    (26.0 * scale).clamp(16.0, 26.0);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: (16.0 * scale).clamp(8.0, 16.0),
                              ),
                              child: Text(
                                translated
                                    ? translatedTexts['question'] ??
                                        originalTexts['question']!
                                    : originalTexts['question']!,
                                style: TextStyle(
                                  fontSize: questionFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontFamily: 'ComicNeue',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (feedbackText.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: (8.0 * scale).clamp(4.0, 8.0),
                                ),
                                child: Text(
                                  feedbackText,
                                  style: TextStyle(
                                    fontSize: feedbackFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: feedbackText.contains("✅")
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            SizedBox(height: (20.0 * scale).clamp(6.0, 20.0)),
                            _buildBalloonsRow(screenWidth, balloonSize),
                          ],
                        ),
                        _buildMascotSection(scale),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloonsRow(double screenWidth, double balloonSize) {
    final double balloonFontSize =
        (35.0 * (balloonSize / 210.0)).clamp(15.0, 35.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: screenWidth > 0 ? screenWidth : 320.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: shuffledOptions.asMap().entries.map((entry) {
              int index = entry.key;
              double option = entry.value;
              final imagePath = getBalloonAsset(index);

              return GestureDetector(
                onTap: () => checkAnswer(option),
                child: ScaleTransition(
                  scale: _animations[index],
                  child: SizedBox(
                    width: balloonSize,
                    height: balloonSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        Align(
                          alignment: const Alignment(0, -0.6),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: balloonSize * 0.1,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                option.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: balloonFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'ComicNeue',
                                ),
                              ),
                            ),
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
    );
  }

  Widget _buildMascotSection(double scale) {
    final double iconSize = (75.0 * scale).clamp(36.0, 75.0);
    final double maxWidth = (180.0 * scale).clamp(120.0, 180.0);
    final double fontSize = (16.0 * scale).clamp(11.0, 16.0);
    final double paddingVal = (10.0 * scale).clamp(6.0, 10.0);
    final double leftPadding = (40.0 * scale).clamp(16.0, 40.0);
    final double bottomPadding = (10.0 * scale).clamp(6.0, 10.0);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          bottom: bottomPadding,
          top: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _speakQuestionAndOptions,
              child: AnimatedBuilder(
                animation: _mascotBounce,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_mascotBounce.value),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.volume_up,
                  size: iconSize,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(paddingVal),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                mascotMessage,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
