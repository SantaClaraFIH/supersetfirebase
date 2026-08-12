import 'dart:math'; // Import for random selection
import 'package:supersetfirebase/gamescreen/mathdecimals/selection_pages/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late SharedPreferences _preferences;
  final Map<String, String> originalTexts = {
    'heading':
        'Lets play matching! Match each underlined value to the correct units:',
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

  final List<Map<String, String>> questionSets = [
    {
      '0.444': 'Thousandths',
      '0.73': 'Hundredths',
      '61': 'Tens',
      '1.13': 'Tenths',
      '7842': 'Thousands',
      '5': 'Ones'
    },
    {
      '0.89': 'Hundredths',
      '92': 'Tens',
      '0.6': 'Tenths',
      '4567': 'Thousands',
      '3': 'Ones',
      '0.234': 'Thousandths'
    },
    {
      '0.15': 'Hundredths',
      '45': 'Tens',
      '1.2': 'Tenths',
      '6789': 'Thousands',
      '7': 'Ones',
      '0.098': 'Thousandths'
    },
    // Adding new questions
    {
      '0.42': 'Hundredths',
      '50': 'Tens',
      '2.3': 'Tenths',
      '1450': 'Thousands',
      '0': 'Ones',
      '0.118': 'Thousandths'
    },
    {
      '0.45': 'Hundredths',
      '10': 'Tens',
      '1.92': 'Tenths',
      '1750': 'Thousands',
      '20': 'Ones',
      '4.123': 'Thousandths'
    },
    {
      '0.32': 'Hundredths',
      '101': 'Tens',
      '2.1': 'Tenths',
      '3349': 'Thousands',
      '4': 'Ones',
      '10.091': 'Thousandths'
    },
    {
      '1.31': 'Hundredths',
      '13': 'Tens',
      '4.6': 'Tenths',
      '6162': 'Thousands',
      '81': 'Ones',
      '0.438': 'Thousandths'
    },
    {
      '5.24': 'Hundredths',
      '11': 'Tens',
      '4.2': 'Tenths',
      '6763': 'Thousands',
      '42': 'Ones',
      '5.987': 'Thousandths'
    },
  ]; // Multiple sets of questions

  late Map<String, String> correctPairs;
  late List<String> items;
  List<String> selectedItems = [];
  int score = 0;
  int bestScore = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewRound();
    _loadBestScore();
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

  void _generateNewRound() {
    setState(() {
      int randomIndex = random.nextInt(questionSets.length);
      correctPairs = questionSets[randomIndex]; // Pick a random set
      items = correctPairs.entries
          .expand((e) => [e.key, e.value])
          .toList(); // Flatten into a list
      items.shuffle(); // Shuffle the items for randomness
      selectedItems.clear();
      score = score;
      _saveBestScore(score);
    });
  }

  // Method to navigate to a specific page when back button is pressed
  void _navigateToCustomPage() {
    // Navigate to a specific page - replace BirdGameScreen() with your desired destination
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

  void checkMatch() async {
    if (selectedItems.length == 2) {
      final String first = selectedItems[0];
      final String second = selectedItems[1];

      if ((correctPairs[first] == second) || (correctPairs[second] == first)) {
        await _playSound('MathDecimals/sounds/success.mp3');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ));
        setState(() {
          items.remove(first);
          items.remove(second);
        });

        if (items.isEmpty) {
          setState(() {
            score += 10;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            _showCompletionDialog();
          });
        }
      } else {
        await _playSound('MathDecimals/sounds/error.mp3');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Incorrect!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ));
      }
      selectedItems.clear();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          // Rounded corners and a playful pastel background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,

          title: Column(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.lightGreen, size: 32),
              const SizedBox(width: 8),
              Text(
                "  Success!   ",
                style: TextStyle(
                  color: Color(0xFF1f6924),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Content in a bright contrasting color
          content: Text(
            "You matched all the pairs!\nPlay the next round?",
            style: TextStyle(
                color: Colors.lightGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          // Center the action and use a colorful, rounded button
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, // formerly `primary`
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _generateNewRound();
              },
              child: const Text(
                "Next Round!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

// change this function - previously was hardcoded
  Widget buildUnderlinedText(String text, String? unit) {
    // handle the case when no unit - shouldn't happen
    if (unit == null) {
      return Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }
    final parts = text.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';
    int underlineIndex = -1;
    if (unit == 'Thousands') {
      underlineIndex = intPart.length - 4;
    } else if (unit == 'Tens') {
      underlineIndex = intPart.length - 2;
    } else if (unit == 'Ones') {
      underlineIndex = intPart.length - 1;
    } else if (unit == 'Tenths') {
      underlineIndex = 0;
    } else if (unit == 'Hundredths') {
      underlineIndex = 1;
    } else if (unit == 'Thousandths') {
      underlineIndex = 2;
    }
    List<InlineSpan> spans = [];

    if (unit == 'Thousands' || unit == 'Tens' || unit == 'Ones') {
      for (int i = 0; i < intPart.length; i++) {
        spans.add(TextSpan(
          text: intPart[i],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: i == underlineIndex ? TextDecoration.underline : null,
          ),
        ));
      }
      if (decPart.isNotEmpty) {
        spans.add(TextSpan(
          text: '.',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ));
        spans.addAll(decPart.split('').map((c) => TextSpan(
              text: c,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )));
      }
    } else {
      spans.add(TextSpan(
        text: intPart + (decPart.isNotEmpty ? '.' : ''),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ));
      for (int i = 0; i < decPart.length; i++) {
        spans.add(TextSpan(
          text: decPart[i],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: i == underlineIndex ? TextDecoration.underline : null,
          ),
        ));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: RichText(
            text: TextSpan(style: const TextStyle(fontSize: 24), children: [
          const TextSpan(text: "Match the Tiles! "),
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
                  : 'assets/MathDecimals/b2.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  translated
                      ? translatedTexts['heading'] ?? originalTexts['heading']!
                      : originalTexts['heading']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LuckiestGuy', // a playful kids’ font
                    fontSize: screenWidth > 1200 ? 25.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f6924),
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    left: screenWidth > 1200 ? 350.0 : 16.0,
                    right: screenWidth > 1200 ? 350.0 : 16.0,
                    bottom: screenWidth > 1200 ? 350.0 : 16.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final String item = items[index];
                    final bool isSelected = selectedItems.contains(item);
                    return GestureDetector(
                      onTap: () {
                        if (selectedItems.contains(item)) return;
                        setState(() {
                          selectedItems.add(item);
                        });
                        checkMatch();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange.shade200
                                : Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.orange, width: 2)
                                : Border.all(color: Colors.purple, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: correctPairs.containsKey(item)
                              ? buildUnderlinedText(item, correctPairs[item])
                              : correctPairs.containsValue(item)
                                  ? Text(
                                      item,
                                      style: TextStyle(
                                        fontSize:
                                            screenWidth > 1200 ? 22.0 : 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(item) // fallback
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
