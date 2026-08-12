import 'dart:math';

import 'package:supersetfirebase/gamescreen/mathdecimals/selection_pages/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseItGameScreen extends StatefulWidget {
  const ChooseItGameScreen({super.key});

  @override
  _ChooseItGameScreenState createState() => _ChooseItGameScreenState();
}

class _ChooseItGameScreenState extends State<ChooseItGameScreen> {
  late SharedPreferences _preferences;
  final FlutterTts _flutterTts = FlutterTts();
  final Map<String, String> originalTexts = {
    'heading': 'What is the correct description for',
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

  final List<Map<String, dynamic>> _questions = [
    {
      'number': 38.29,
      'description': 'Thirty Eight and Twenty Nine Hundredths',
      'options': [
        'Thirty Eight and Twenty Eight Hundredths',
        'Thirty Seven and Twenty Nine Hundredths',
        'Thirty Nine and Twenty Nine Hundredths',
        'Thirty Eight and Twenty Nine Hundredths', // Correct answer
      ]
    },
    {
      'number': 453.01,
      'description': 'Four Hundred Fifty Three and One Hundredths',
      'options': [
        'Four Hundred Fifty Three and One Thousandth',
        'Four Hundred Fifty Four and One Hundredths',
        'Four Hundred Fifty Three and Ten Hundredths',
        'Four Hundred Fifty Three and One Hundredths', // Correct answer
      ]
    },
    {
      'number': 0.75,
      'description': 'Seventy Five Hundredths',
      'options': [
        'Seventy Five Tenths',
        'Seventy Five Thousandths',
        'Seven and Fifty Hundredths',
        'Seventy Five Hundredths', // Correct answer
      ]
    },
    {
      'number': 5.6,
      'description': 'Five and Six Tenths',
      'options': [
        'Five and Sixty Tenths',
        'Five and Six Hundredths',
        'Six and Five Tenths',
        'Five and Six Tenths', // Correct answer
      ]
    },
    {
      'number': 91.82,
      'description': 'Ninety One and Eighty Two Hundredths',
      'options': [
        'Ninety One and Eighty Two Thousandths',
        'Ninety and Eighty Two Hundredths',
        'Ninety One and Eight Hundredths',
        'Ninety One and Eighty Two Hundredths', // Correct answer
      ]
    },
    {
      'number': 123.004,
      'description': 'One Hundred and Twenty Three and Four Thousandths',
      'options': [
        'One Hundred Twenty Three and Four Hundredths',
        'One Hundred Twenty Three and Forty Thousandths',
        'One Hundred and Twenty Three and Four Thousandths', // Correct answer
        'One Hundred and Twenty Three and Four Hundredths',
      ]
    },
    {
      'number': 65.38,
      'description': 'Sixty Five and Thirty Eight Hundredths',
      'options': [
        'Sixty Six and Thirty Eight Hundredths',
        'Sixty Five and Three Hundred Eight Tenths',
        'Sixty Five and Thirty Eight Thousandths',
        'Sixty Five and Thirty Eight Hundredths', // Correct answer
      ]
    },
    {
      'number': 4.007,
      'description': 'Four and Seven Thousandths',
      'options': [
        'Four and Seventy Hundredths',
        'Four and Seventy Thousandths',
        'Four and Seven Tenths',
        'Four and Seven Thousandths', // Correct answer
      ]
    },
  ];

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _navigateToCustomPage() {
    _saveBestScore(score);
    Navigator.of(context).pop(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  void _navigateToHome() {
    _saveBestScore(score);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  int currentQuestionIndex = 0;
  int score = 0;
  int bestScore = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String selectedAnswer = '';

  @override
  void initState() {
    super.initState();
    _shuffleQuestions(); // Shuffle questions when the widget initializes
    _loadBestScore();
  }

  // Create a copy to avoid modifying the original
  List<Map<String, dynamic>> questions = [];
  void _shuffleQuestions() {
    var random = Random();
    questions = [..._questions];
    for (var i = questions.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = questions[i];
      questions[i] = questions[n];
      questions[n] = temp;
      List options = questions[i]['options'];
      for (var j = options.length - 1; j > 0; j--) {
        var m = random.nextInt(j + 1);
        var tempOption = options[j];
        options[j] = options[m];
        options[m] = tempOption;
      }
    }
  }

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

  void checkAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      score = score;
      _saveBestScore(score);
    });

    if (answer == questions[currentQuestionIndex]['description']) {
      score += 10;
      await _playSound('sounds/success.mp3');
    } else {
      await _playSound('sounds/error.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    String question = questions[currentQuestionIndex]['number'].toString();
    String correctAnswer = questions[currentQuestionIndex]['description'];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: RichText(
            text: TextSpan(style: const TextStyle(fontSize: 24), children: [
          const TextSpan(text: "Choose It Game! "),
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
            onPressed: _navigateToHome,
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
              screenWidth > 1200
                  ? 'assets/MathDecimals/matchitbackground.png'
                  : 'assets/MathDecimals/top2.png',
              fit: screenWidth > 1200 ? BoxFit.cover : BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Expanded(
                      Text(
                        translated
                            ? '${translatedTexts['heading'] ?? originalTexts['heading']} $question?'
                            : '${originalTexts['heading']} $question?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (selectedAnswer.isNotEmpty)
                        Padding(
                          padding:
                              EdgeInsets.only(left: 8.0), // Added padding here
                          child: IconButton(
                            onPressed: () => _speak(correctAnswer),
                            icon: const Icon(Icons.volume_up),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (var option in questions[currentQuestionIndex]['options'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedAnswer.isEmpty
                              ? Colors.purple
                              : option == correctAnswer
                                  ? Colors.green
                                  : selectedAnswer != correctAnswer &&
                                          option == selectedAnswer
                                      ? Colors.red
                                      : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(option),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (selectedAnswer.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (currentQuestionIndex < questions.length - 1) {
                                currentQuestionIndex++;
                                selectedAnswer = '';
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: Colors.white,
                                      title: const Text(
                                        "  Game Over  ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                        'Your score: $score/${(questions.length) * 10}',
                                        style: const TextStyle(
                                            color: Colors.lightGreen,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              score = 0;
                                              currentQuestionIndex = 0;
                                              selectedAnswer = '';
                                              Navigator.of(context).pop();
                                              _shuffleQuestions();
                                            });
                                          },
                                          child: const Text(
                                            "Restart",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Next question'),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
