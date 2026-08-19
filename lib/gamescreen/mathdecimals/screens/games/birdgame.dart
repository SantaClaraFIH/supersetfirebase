import 'package:supersetfirebase/gamescreen/mathdecimals/selection_pages/GameSelectionDialog.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LizzieTheBirdGame extends StatefulWidget {
  const LizzieTheBirdGame({super.key});

  @override
  _LizzieTheBirdGameState createState() => _LizzieTheBirdGameState();
}

class _LizzieTheBirdGameState extends State<LizzieTheBirdGame> {
  late SharedPreferences _preferences;
  String feedback = "";
  Color feedbackColor = Colors.black;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool showBubble = false;
  bool birdMoves = false;
  double birdTop = 200; // Initial position
  double birdLeft = 450; // Initial position // Initial bird position
  int currentQuestionIndex = 0;
  int score = 0;
  int bestScore = 0;
  String selectedAnswer = '';
  final FlutterTts _flutterTts = FlutterTts();

  final GlobalKey _correctFishKey = GlobalKey();
  Set<String> hiddenFishes = {};
  final Map<String, String> originalTexts = {
    'heading': 'Help me choose the right fish to eat!\n',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _shuffleQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

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

  final List<Map<String, dynamic>> questions = [
    {
      'number': 0.25,
      'description': '25 Hundredths',
      'options': [
        '0.025',
        '0.25',
        '2.5',
        '0.0025',
      ]
    },
    {
      'number': 0.007,
      'description': '7 Thousandths',
      'options': [
        '0.07',
        '0.007',
        '0.7',
        '0.0007',
      ]
    },
    {
      'number': 3.14,
      'description': '3 and 14 Hundredths',
      'options': [
        '3.14',
        '3.014',
        '31.4',
        '0.314',
      ]
    },
    {
      'number': 0.63,
      'description': 'Sixty three hundredth',
      'options': [
        '0.603',
        '0.63',
        '6.03',
        '0.063',
      ]
    },
    {
      'number': 48,
      'description': 'Forty Eight',
      'options': [
        '0.48',
        '4.8',
        '48',
        '480',
      ]
    },
    {
      'number': 0.2,
      'description': '2 Tenths',
      'options': [
        '0.2',
        '0.02',
        '0.002',
        '2',
      ]
    },
    {
      'number': 0.123,
      'description': 'one hundred twenty-three thousandths',
      'options': [
        '0.12',
        '123',
        '0.123',
        '0.0123',
      ]
    },
    {
      'number': 0.009,
      'description': 'Nine thousandths',
      'options': [
        '0.09',
        '0.009',
        '0.0009',
        '0.9',
      ]
    },
  ];

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _shuffleQuestions() {
    setState(() {
      questions.shuffle();
      for (var question in questions) {
        (question['options'] as List<String>).shuffle();
      }
    });
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
    _saveBestScore(score);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showEndGameDialog() {
    _saveBestScore(score);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Good Job!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your final score: $score'),
                Text('Best Score: $bestScore'),
                const SizedBox(height: 20),
                const Text('Do you want to play again?'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text("Restart"),
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToHome();
                  },
                  child: const Text("Exit"))
            ],
          );
        });
  }

  void _resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      // do not clear the score
      selectedAnswer = '';
      feedback = '';
      feedbackColor = Colors.black;
      showBubble = false;
      birdMoves = false;
      hiddenFishes.clear();
      // Reset bird position to initial values
      birdTop = MediaQuery.of(context).size.height * 0.2;
      birdLeft = MediaQuery.of(context).size.width * 0.35;
    });
  }

  void checkAnswer(String answer) {
    final String correctValue =
        questions[currentQuestionIndex]['number'].toString();

    setState(() {
      selectedAnswer = answer;

      if (answer == correctValue) {
        feedback = "Correct!";
        feedbackColor = Colors.green;
        _playSound('MathDecimals/sounds/success.mp3');
        showBubble = true;
        score += 10;
        _saveBestScore(score);

        // get position of the correct fish
        final renderBox =
            _correctFishKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Offset position = renderBox.localToGlobal(Offset.zero);
          setState(() {
            birdTop = position.dy - 50;
            birdLeft = position.dx;
            birdMoves = true;
          });
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            hiddenFishes.add(answer);
            birdMoves = false;
            birdTop = MediaQuery.of(context).size.height * 0.2;
            birdLeft = MediaQuery.of(context).size.width * 0.35;
            feedbackColor = Colors.black;
          });
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            showBubble = false;
            if (currentQuestionIndex < questions.length - 1) {
              hiddenFishes.clear();
              currentQuestionIndex++;
            } else {
              _showEndGameDialog();
            }
          });
        });
      } else {
        feedback = "Try Again!";
        feedbackColor = Colors.red;
        _playSound('MathDecimals/sounds/error.mp3');
        showBubble = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => showBubble = false);
          feedbackColor = Colors.black;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String question = questions[currentQuestionIndex]['description'];

    // birdLeft = screenWidth < 1200 ? birdLeft - 60 : birdLeft - 160;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: RichText(
            text: TextSpan(style: const TextStyle(fontSize: 24), children: [
          const TextSpan(text: "Lizzie the Bird! "),
          TextSpan(
              text: "Score: $score",
              style: TextStyle(fontWeight: FontWeight.bold))
        ])),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        actions: [
          Text(
            "Best Score: $bestScore",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // double width = constraints.maxWidth < 1200
                //     ? screenWidth
                //     : screenWidth * 0.4;

                return Image.asset(
                  'assets/MathDecimals/backdrop2.jpeg',
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          Positioned(
            top: screenWidth < 500 ? screenHeight * 0.15 : screenHeight * 0.15,
            left: screenWidth * 0.035,
            right: 0,
            child: Column(
              children: [
                Container(
                  // padding: const EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(15),
                  // ),
                  child: Text(
                    translated
                        ? '${translatedTexts['heading'] ?? originalTexts['heading']} $question?'
                        : '${originalTexts['heading']} $question?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: feedbackColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 488.0),
                  child: IconButton(
                    onPressed: () =>
                        _speak('${originalTexts['heading']} $question?'),
                    icon: const Icon(Icons.volume_up),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: birdMoves ? birdTop : screenHeight * 0.2,
            left: birdMoves ? birdLeft : screenWidth * 0.35,
            child: Image.asset(
              'assets/MathDecimals/birdnew.png',
              width: screenWidth * 0.3,
              height: screenHeight * 0.2,
              fit: BoxFit.contain,
            ),
          ),

          // Speech Bubble
          if (showBubble)
            Positioned(
              top: screenWidth < 500
                  ? (screenHeight * 0.4) - 60
                  : (screenHeight * 0.3) - 40,
              left: screenWidth < 1200 ? screenWidth * 0.6 : screenWidth * 0.55,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  feedback,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: feedbackColor),
                ),
              ),
            ),

          // Fish Buttons
          Positioned(
            bottom: screenWidth * 0.05,
            left: screenWidth * 0.03,
            right: screenWidth * 0.03,
            child: Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenHeight * 0.01,
              alignment: WrapAlignment.center,
              children: [
                for (var option in questions[currentQuestionIndex]['options'])
                  if (!hiddenFishes.contains(option))
                    buildFishButton(option, screenWidth, screenHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFishButton(
      String value, double screenWidth, double screenHeight) {
    final String correctValue =
        questions[currentQuestionIndex]['number'].toString();
    final bool isCorrect = value == correctValue;
    double fishBaseSize = screenWidth * 0.18;
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        // only the correct fish gets the key:
        key: isCorrect ? _correctFishKey : null,
        width: fishBaseSize,
        height: fishBaseSize * 0.8,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/MathDecimals/fishnew.png'),
          ),
        ),
        alignment: Alignment(0.2, 0),
        child: Container(
          child: Text(
            value,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 20 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
