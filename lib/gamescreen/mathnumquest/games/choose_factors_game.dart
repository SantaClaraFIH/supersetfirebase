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
      appBar: AppBar(
          title: Text(t('Choose factors of the given number', 'Elige los factores del número dado')),
          actions: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  isEnglish = !isEnglish;
                });
                AnalyticsEngine.logGameTranslateButtonClick(); 
              },
              label: Text(
                isEnglish ? "Tap to Translate" : "Toca para Traducir",
                style: const TextStyle(color: Colors.orange, fontSize: 18,fontWeight: FontWeight.bold),
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Bigschooldesk_generated.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t('Round $roundNumber', 'Ronda $roundNumber'), style: TextStyle(fontSize: 24)),
                  SizedBox(height: 30),
                  Text(t('Select the Factors of $generatedNumber', 'Selecciona los factores de $generatedNumber'),
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(20, (index) {
                        return SizedBox(
                          width: 40,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (selectedFactors.contains(index + 1)) {
                                  selectedFactors.remove(index + 1);
                                } else {
                                  selectedFactors.add(index + 1);
                                }
                              });
                            },
                            child: Text('${index + 1}', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: selectedFactors.contains(index + 1)
                                  ? Colors.green
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton(onPressed: checkAnswer, child: Text(t('Check', 'Verificar'), style: TextStyle(fontSize: 18))),
                  ElevatedButton(onPressed: nextRound, child: Text(t('Next Round', 'Siguiente Ronda'), style: TextStyle(fontSize: 18))),
                  ElevatedButton(onPressed: resetGame, child: Text(t('Reset Game', 'Reiniciar Juego'), style: TextStyle(fontSize: 18))),
                  Text(
                    feedback,
                    style: TextStyle(
                      fontSize: 20,
                      color: isCorrect == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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