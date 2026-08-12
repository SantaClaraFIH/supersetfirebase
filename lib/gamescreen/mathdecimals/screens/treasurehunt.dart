import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:supersetfirebase/services/translation_service.dart';

// Comment out the runApp functionality; this page is a child of main.dart
// void main() {
//   runApp(DecimalTreasureHuntGame());
// }

class DecimalTreasureHuntGame extends StatelessWidget {
  const DecimalTreasureHuntGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const TreasureHuntScreen();
  }
}

class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int score = 0;
  late String number;
  late String question;
  late String selectedPlace;
  late int correctAnswer;

  final Map<String, String> originalTexts = {
    'heading': 'Find the digit in the {place} place of {number}',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;

  final List<String> places = [
    'Ones',
    'Tens',
    'Hundreds',
    'Tenths',
    'Hundredths',
    'Thousandths'
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    number = (_random.nextDouble() * 1000).toStringAsFixed(3);
    selectedPlace = places[_random.nextInt(places.length)];
    Map<String, int> placeIndex = {
      'Ones': number.indexOf('.') - 1,
      'Tens': number.indexOf('.') - 2,
      'Hundreds': number.indexOf('.') - 3,
      'Tenths': number.indexOf('.') + 1,
      'Hundredths': number.indexOf('.') + 2,
      'Thousandths': number.indexOf('.') + 3,
    };

    int idx = placeIndex[selectedPlace]!;
    correctAnswer = (idx >= 0 && idx < number.length)
        ? int.parse(number[idx])
        : 0;
    question = 'Find the digit in the $selectedPlace place of $number';
    // final rawTemplate = translated
    //     ? (translatedTexts['heading'] ?? originalTexts['heading']!)
    //     : originalTexts['heading']!;
    // question = rawTemplate
    //     .replaceAll('{place}', selectedPlace)
    //     .replaceAll('{number}', number);
  }
  void _buildQuestionText() {
    // Choose the right template (English or Spanish)
    final rawTemplate = translated
        ? (translatedTexts['heading'] ?? originalTexts['heading']!)
        : originalTexts['heading']!;

    // Replace placeholders in that template
    question = rawTemplate
        .replaceAll('{place}', selectedPlace)
        .replaceAll('{number}', number);
  }


  Future<void> translateTexts() async {
    if (!translated) {
      try {
        final translations = await TranslationService.translateMap(originalTexts);
        setState(() {
          translatedTexts = translations;
          translated = true;
          _buildQuestionText(); // <- regenerate with translated template
        });
      } catch (e) {
        debugPrint('Failed to fetch translations: $e');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
        _buildQuestionText();
      });
    }
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _checkAnswer(int selected) async {
    if (selected == correctAnswer) {
      await _playSound('sounds/success.mp3');
      setState(() {
        score += 10;
        _generateQuestion();
      });
    } else {
      await _playSound('sounds/error.mp3');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          // title: const Text('Try Again', style: TextStyle(color: Colors.red)),
          title: Column(
              children: [
              Icon( Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(width: 8), Text(
            "  Try Again  ",
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          ],
          ),
          // content: Text("Oops! $selected is incorrect."),
          content: Text(
            "Oops! $selected is incorrect",
            style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,   // formerly `primary`
                foregroundColor: Colors.white,               // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () =>
                Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Decimal Treasure Hunt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
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
                  : 'assets/MathDecimals/b2.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  question,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 1200 ? 5 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _checkAnswer(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
