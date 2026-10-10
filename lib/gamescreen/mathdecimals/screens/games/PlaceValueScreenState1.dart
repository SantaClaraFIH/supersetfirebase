import 'package:supersetfirebase/gamescreen/mathdecimals/selection_pages/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceValueScreen1 extends StatefulWidget {
  const PlaceValueScreen1({super.key});

  @override
  _PlaceValueScreenState1 createState() => _PlaceValueScreenState1();
}

class _PlaceValueScreenState1 extends State<PlaceValueScreen1> {
  late final List<Map<String, String>> _initialQuestions;
  late SharedPreferences _preferences;
  late List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _initialQuestions = List<Map<String, String>>.from(questions);
    questions.shuffle(Random());
    _shuffledOptions = [...extraOptions]..shuffle(Random());
    _loadBestScore();
  }

  final Map<String, String> originalTexts = {
    'heading': 'Match Each Number with its Place Value:',
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
        translated = false; // Mark as untranslated
      });
    }
  }

  final List<Map<String, String>> questions = [
    {
      '1': 'Tens',
      '7': 'Ones',
      '.': 'Decimal',
      '6': 'Tenths',
      '2': 'Hundredths',
      '5': 'Thousandths',
    },
    {
      '5': 'Tens',
      '8': 'Ones',
      '.': 'Decimal',
      '3': 'Tenths',
      '2': 'Hundredths',
    },
    {
      '0': 'Ones',
      '.': 'Decimal',
      '7': 'Tenths',
      '2': 'Hundredths',
      '1': 'Thousandths',
    },
    {
      '8': 'Hundreds',
      '6': 'Tens',
      '4': 'Ones',
    },
    {
      '3': 'Tens',
      '9': 'Ones',
      '.': 'Decimal',
      '4': 'Tenths',
      '6': 'Hundredths',
      '1': 'Thousandths',
    },
    {
      '7': 'Ones',
      '.': 'Decimal',
      '5': 'Tenths',
      '3': 'Hundredths',
    },
    {
      '2': 'Ones',
      '.': 'Decimal',
      '8': 'Tenths',
      '0': 'Hundredths',
      '4': 'Thousandths',
    },
    {
      '6': 'Thousands',
      '2': 'Hundreds',
      '1': 'Tens',
      '9': 'Ones',
    },
  ];

  final List<String> extraOptions = [
    'Tens',
    'Ones',
    'Tenths',
    'Hundredths',
    'Thousandths',
    'Seven',
    'Thousands',
    'Hundreds',
    'Oneths',
    'Sevenths',
    'Decimal',
  ];

  final Map<String, String> draggedItems = {};
  final Map<String, bool> feedback = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  int score = 0;
  int bestScore = 0;
  int currentQuestionIndex = 0;

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown
  ];

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> _loadBestScore() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      bestScore = _preferences.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore(int newBest) async {
    if (newBest > bestScore) {
      setState(() {
        bestScore = newBest;
      });
      await _preferences.setInt('bestScore', newBest);
    }
  }

  // Method to navigate to a specific page when back button is pressed
  void _navigateToCustomPage() {
    _saveBestScore(score);
    Navigator.of(context).pop(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  // Method to handle home button press
  void _navigateToHome() {
    // Navigate to home screen
    _saveBestScore(score);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 22, color: Colors.white),
              children: [
                const TextSpan(text: "Match it! "),
                TextSpan(
                  text: " Score: $score",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          Center(
            child: Text(
              "Best: $bestScore",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {
              _navigateToHome();
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MathDecimals/b2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: _buildGameContent(constraints),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BoxConstraints constraints) {
    final double screenWidth = constraints.maxWidth;
    final double screenHeight = constraints.maxHeight;

    final bool isSmall = screenWidth < 700 || screenHeight < 650;
    final bool isVerySmall = screenWidth < 450 || screenHeight < 500;

    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Great job! All questions completed!',
                style: TextStyle(
                  fontSize: isSmall ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    questions.addAll(_initialQuestions);
                    questions.shuffle(Random());
                    score = 0;
                    draggedItems.clear();
                    feedback.clear();
                    _shuffledOptions = [...extraOptions]..shuffle(Random());
                  });
                },
                child: const Text('Restart Game'),
              ),
            ],
          ),
        ),
      );
    }

    final double headingFontSize = isVerySmall ? 15 : (isSmall ? 17 : 20);
    final double numberFontSize = isVerySmall ? 26 : (isSmall ? 32 : 40);

    final int numDigits = questions.first.keys.length;
    final double targetSpacing = isVerySmall ? 4.0 : (isSmall ? 6.0 : 8.0);
    final double horizontalPadding = isVerySmall ? 8.0 : (isSmall ? 12.0 : 16.0);
    final double availableWidth = screenWidth - (horizontalPadding * 2);
    final double calculatedTargetWidth = numDigits > 0
        ? ((availableWidth - ((numDigits - 1) * targetSpacing)) / numDigits)
        : 100.0;
    final double targetWidth =
        calculatedTargetWidth.clamp(isVerySmall ? 42.0 : 50.0, 100.0);
    final double targetHeight = isVerySmall ? 36.0 : (isSmall ? 42.0 : 50.0);
    final double targetFontSize = isVerySmall ? 11.0 : (isSmall ? 13.0 : 15.0);

    final double optionFontSize = isVerySmall ? 12.0 : (isSmall ? 13.0 : 15.0);
    final EdgeInsets optionPadding = isVerySmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : (isSmall
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8));
    final double optionSpacing = isVerySmall ? 6.0 : (isSmall ? 8.0 : 10.0);
    final double verticalGap = isVerySmall ? 8.0 : (isSmall ? 12.0 : 20.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isVerySmall ? 8.0 : 16.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translated
                ? translatedTexts['heading'] ?? originalTexts['heading']!
                : originalTexts['heading']!,
            style: TextStyle(
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: verticalGap),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: questions.first.keys.map((number) {
                int colorIndex = questions.first.keys.toList().indexOf(number) %
                    colors.length;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: targetSpacing / 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColoredNumber(
                          number, colors[colorIndex], numberFontSize),
                      SizedBox(height: isVerySmall ? 4 : 8),
                      _buildDragTarget(
                          number, targetWidth, targetHeight, targetFontSize),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: verticalGap * 1.2),
          _buildDraggableOptions(optionFontSize, optionPadding, optionSpacing),
        ],
      ),
    );
  }

  Widget _buildDraggableOptions(
    double fontSize,
    EdgeInsets padding,
    double spacing,
  ) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: _shuffledOptions
          .map((value) => _buildDraggable(value, fontSize, padding))
          .toList(),
    );
  }

  Widget _buildColoredNumber(String number, Color color, double fontSize) {
    return Text(
      number,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildDraggable(String value, double fontSize, EdgeInsets padding) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.teal[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 147, 212, 206),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: fontSize, color: Colors.grey),
        ),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 147, 212, 206),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  Widget _buildDragTarget(
      String key, double width, double height, double fontSize) {
    return DragTarget<String>(
      onAcceptWithDetails: (value) {
        setState(() {
          if (questions.first[key] == value.data) {
            draggedItems[key] = value.data;
            feedback[key] = true;
            _playSound('MathDecimals/sounds/success.mp3');
          } else {
            feedback[key] = false;
            _playSound('MathDecimals/sounds/error.mp3');
          }
          bool allCorrect = true;
          for (var entry in questions.first.entries) {
            if (draggedItems[entry.key] != entry.value) {
              allCorrect = false;
              break;
            }
          }
          if (allCorrect && draggedItems.length == questions.first.length) {
            score += 10;
            _saveBestScore(score);
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  questions.removeAt(0);
                  draggedItems.clear();
                  feedback.clear();
                  _shuffledOptions = [...extraOptions]..shuffle(Random());
                });
              }
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: draggedItems[key] != null ? Colors.green[100] : Colors.white,
          ),
          alignment: Alignment.center,
          child: draggedItems[key] != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      draggedItems[key]!,
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Drop here',
                      style: TextStyle(fontSize: fontSize, color: Colors.grey),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
