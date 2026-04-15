import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart'; // Import analytics engine

void main() {
  runApp(ChooseFactorsGame());
}

class ChooseFactorsGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select the factors of the given number',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DartGamePage(),
    );
  }
}

class DartGamePage extends StatefulWidget {
  final bool isEnglish;

  const DartGamePage({Key? key, this.isEnglish = true}) : super(key: key); 

  @override
  _DartGamePageState createState() => _DartGamePageState();
}

class _DartGamePageState extends State<DartGamePage> {
  int roundNumber = 1;
  int generatedNumber = 0;
  List<int> selectedFactors = [];
  String feedback = '';
  bool? isCorrect;
  late FlutterTts flutterTts;
  late ConfettiController _confettiController;
  final String gameType = 'choose_factors'; // Define game type
  int totalScore = 0; // Track total score for analytics
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;
    flutterTts = FlutterTts();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    generateRound();
    
    // Log game start when the game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void generateRound() {
    setState(() {
      generatedNumber = Random().nextInt(20) + 1;
      selectedFactors.clear();
      feedback = '';
      isCorrect = null;
    });
  }

  List<int> _calculateFactors(int number) {
    List<int> factors = [];
    for (int i = 1; i <= number; i++) {
      if (number % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }

  void checkAnswer() async {
    List<int> factors = _calculateFactors(generatedNumber);
    bool correct = true;
    for (int factor in factors) {
      if (!selectedFactors.contains(factor)) {
        correct = false;
        break;
      }
    }
    setState(() {
      isCorrect = correct && factors.length == selectedFactors.length;
      feedback = isCorrect! ? t('Correct!', '¡Correcto!') : t('Incorrect!', '¡Incorrecto!');
      
      // Add to score if correct
      if (isCorrect!) {
        totalScore += 10;
      }
    });

    if (isCorrect!) {
      _confettiController.play();
      await flutterTts.speak(isEnglish ? "Correct!" : "¡Correcto!");

    } else {
      await flutterTts.speak(isEnglish? "Incorrect" : "Inténtalo de nuevo!");
    }
  }

  void nextRound() {
    setState(() {
      if (roundNumber < 5) {
        roundNumber++;
        generateRound();
      } else {
        // Log game completion with final score
        AnalyticsEngine.logGameComplete(gameType, totalScore);
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Game Over'),
              content: Text('Thanks for playing!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: Text('Play Again'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void resetGame() {
    setState(() {
      roundNumber = 1;
      totalScore = 0; // Reset score
      generateRound();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE0F2F1),
    appBar: AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF004D40),
      title: Text(
        t('Choose factors of the given number',
            'Elige los factores del número dado'),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          backgroundColor: const Color(0xFF004D40)
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              isEnglish = !isEnglish;
            });
            AnalyticsEngine.logGameTranslateButtonClick();
          },
          child: Text(
            isEnglish ? "Translate" : "Traducir",
            style: const TextStyle(
              color: Color(0xFF80CBC4),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
          AnalyticsEngine.logGameCompleteInMiddle();
        },
      ),
    ),
    body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB2DFDB), Color(0xFF80CBC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3300897B),
                      blurRadius: 24,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      t('Round $roundNumber', 'Ronda $roundNumber'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t('Select the Factors of $generatedNumber',
                          'Selecciona los factores de $generatedNumber'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF004D40),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    /// NUMBER GRID
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(20, (index) {
                        final number = index + 1;
                        final selected =
                            selectedFactors.contains(number);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                selectedFactors.remove(number);
                              } else {
                                selectedFactors.add(number);
                              }
                            });
                          },
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF26A69A),
                                        Color(0xFF00897B)
                                      ],
                                    )
                                  : null,
                              color: selected
                                  ? null
                                  : Colors.white.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: selected
                                      ? const Color(0x4000897B)
                                      : Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$number',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF004D40),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    /// ACTION BUTTONS
                    _buildPrimaryButton(
                        t('Check', 'Verificar'), checkAnswer),
                    const SizedBox(height: 12),
                    _buildPrimaryButton(
                        t('Next Round', 'Siguiente Ronda'),
                        nextRound),
                    const SizedBox(height: 12),
                    _buildPrimaryButton(
                        t('Reset Game', 'Reiniciar Juego'),
                        resetGame),

                    const SizedBox(height: 24),

                    Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isCorrect == true
                            ? const Color(0xFF004D40)
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF004D40),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

}