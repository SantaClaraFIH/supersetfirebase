import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart'; // Import analytics engine

void main() {
  runApp(
    MaterialApp(
      home: PrimeNumberGame(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class PrimeNumberGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PrimeNumberGrid(),
    );
  }
}

class PrimeNumberGrid extends StatefulWidget {
  final bool isEnglish;
  const PrimeNumberGrid({Key? key, this.isEnglish = true}) : super(key: key);

  @override
  _PrimeNumberGridState createState() => _PrimeNumberGridState();
}

class _PrimeNumberGridState extends State<PrimeNumberGrid> {
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  final List<int> numbers = [];
  final List<int> selectedIndices = [];
  bool showResult = false;
  bool? isCorrect;
  String feedback = '';

  late FlutterTts _tts;
  late ConfettiController _confettiController;
  final String gameType = 'prime_explorer'; // Define game type
  int totalScore = 0; // Track total score for analytics

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;

    _tts = FlutterTts();
    _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    generateRandomNumbers();

    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tts.stop();
    super.dispose();
  }

  void generateRandomNumbers() {
    final random = Random();
    numbers.clear();
    while (numbers.length < 15) {
      numbers.add(random.nextInt(100) + 1);
    }
    selectedIndices.clear();
    showResult = false;
    isCorrect = null;
    feedback = '';
    setState(() {});
  }

  bool isPrime(int n) {
    if (n <= 1) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    final limit = sqrt(n).toInt();
    for (int i = 3; i <= limit; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  // Updated to take EN + ES and use isEnglish
  Future<void> _speak(String en, String es) async {
    try {
      await _tts.stop();
      await _tts.speak(isEnglish ? en : es);
    } catch (e) {
      // ignore speech errors
    }
  }

  Future<void> checkResult() async {
    final primeIndices = <int>{};
    for (int i = 0; i < numbers.length; i++) {
      if (isPrime(numbers[i])) primeIndices.add(i);
    }

    final selectedSet = selectedIndices.toSet();
    final correct = selectedSet.length == primeIndices.length &&
        selectedSet.difference(primeIndices).isEmpty;

    setState(() {
      showResult = true;
      isCorrect = correct;
      feedback = correct
          ? t('Correct', '¡Correcto!')
          : t('Try again', 'Inténtalo de nuevo');

      if (correct) {
        totalScore += 10; // Add to total score for analytics
      }
    });

    if (correct) {
      _confettiController.play();
      await _speak(
        "Correct! Well done",
        "¡Correcto! Bien hecho",
      );
    } else {
      await _speak(
        'Try again',
        'Inténtalo de nuevo',
      );
    }
  }

  void resetBoard() {
    generateRandomNumbers();
    // Log new game start
    AnalyticsEngine.logGameStart(gameType);
  }

  void nextRound() {
    generateRandomNumbers();
  }

  // Method to end game and log completion (can be called when user decides to finish)
  void endGame() {
    AnalyticsEngine.logGameComplete(gameType, totalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('Prime Number Explorer', 'Explorador de Números Primos'),
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
                _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
              });
              AnalyticsEngine.logGameTranslateButtonClick();
            },
            label: Text(
              isEnglish ? "Tap to Translate" : "Toca para Traducir",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Text(
                    t(
                      'Select all the prime numbers',
                      'Selecciona todos los números primos',
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: feedback.isEmpty ? 0.0 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCorrect == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: numbers.length,
                          itemBuilder: (context, index) {
                            final value = numbers[index];
                            final selected = selectedIndices.contains(index);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    selectedIndices.remove(index);
                                  } else {
                                    selectedIndices.add(index);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.yellow.shade600
                                      : Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      '$value',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: checkResult,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          t('Check', 'Controlar'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: nextRound,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          t('Next', 'Próxima'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: resetBoard,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12),
                        ),
                        child: Text(
                          t('Reset', 'Reiniciar'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
