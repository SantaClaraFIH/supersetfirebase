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

  @override
  void initState() {
    super.initState();
    _initialQuestions = List<Map<String, String>>.from(questions);
    questions.shuffle(Random());
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
    final screenWidth = MediaQuery.of(context).size.width;
    bool shouldRotate = screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
            text: TextSpan(style: const TextStyle(fontSize: 24), children: [
          const TextSpan(text: "Match it! "),
          TextSpan(
              text: " Score: $score",
              style: TextStyle(fontWeight: FontWeight.bold))
        ])),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          Text(
            "Best Score: $bestScore",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
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
              // screenWidth > 1200
              //     ? 'assets/MathDecimals/matchitbackground.png'
              //     : 'assets/MathDecimals/l2.png',
              fit: BoxFit.cover,
            ),
          ),
          _buildGameContent(),
          // shouldRotate
          //     ? RotatedBox(
          //         quarterTurns: 3, // Rotate the screen by 90 degrees
          //         child: _buildGameContent(),
          //       )
          //     : _buildGameContent(),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Great job! All questions completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                });
              },
              child: const Text('Restart Game'),
            ),
          ],
        ),
      );
    }
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translated
                  ? translatedTexts['heading'] ?? originalTexts['heading']!
                  : originalTexts['heading']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              children: questions.first.keys.map((number) {
                int colorIndex = questions.first.keys.toList().indexOf(number) %
                    colors.length;
                return Column(
                  children: [
                    _buildColoredNumber(number, colors[colorIndex]),
                    const SizedBox(height: 10),
                    _buildDragTarget(number),
                  ],
                );
              }).toList(),
            ),
            // const SizedBox(height: 40),
            // _buildFeedbackSection(),
            const SizedBox(height: 20),
            _buildDraggableOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableOptions() {
    final shuffledOptions = [...extraOptions]..shuffle(Random());
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: shuffledOptions.map((value) => _buildDraggable(value)).toList(),
    );
  }

  Widget _buildColoredNumber(String number, Color color) {
    return Text(
      number,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildDraggable(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[300],
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(8),
        color: const Color.fromARGB(255, 147, 212, 206),
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: const Color.fromARGB(255, 147, 212, 206),
        child: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDragTarget(String key) {
    return DragTarget<String>(
      onAcceptWithDetails: (value) {
        setState(() {
          if (questions.first[key] == value.data) {
            draggedItems[key] = value.data;
            feedback[key] = true;
            _playSound('sounds/success.mp3');
          } else {
            feedback[key] = false;
            _playSound('sounds/error.mp3');
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
              setState(() {
                questions.removeAt(0);
                draggedItems.clear();
                feedback.clear();
              });
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: draggedItems[key] != null ? Colors.green[100] : Colors.white,
          ),
          alignment: Alignment.center,
          child: draggedItems[key] != null
              ? Text(
                  draggedItems[key]!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                )
              : const Text(
                  'Drop here',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
        );
      },
    );
  }
}
