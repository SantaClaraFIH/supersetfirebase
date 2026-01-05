import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../game_list_page.dart';
import '../analytics_engine.dart'; // Import analytics engine

class NumberPatternMatchGame extends StatefulWidget {
  final bool isEnglish;
  const NumberPatternMatchGame({Key? key, this.isEnglish = true}) : super(key: key);
  @override
  _NumberPatternMatchGameState createState() => _NumberPatternMatchGameState();
}

class _NumberPatternMatchGameState extends State<NumberPatternMatchGame> {
  late ConfettiController _confettiController;
  late final AudioPlayer _audioPlayer;
  final FlutterTts _flutterTts = FlutterTts();
  final String gameType = 'pattern_match'; // Define game type
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  List<Map<String, dynamic>> questions = [
    {
      'category': 'Prime',
      'correctNumbers': [5],
      'options': [4, 5, 12, 25, 8],
    },
    {
      'category': 'Composite',
      'correctNumbers': [4],
      'options': [4, 5, 3, 2, 7],
    },
    {
      'category': 'Square',
      'correctNumbers': [9],
      'options': [7, 55, 9, 15, 26],
    },
    {
      'category': 'Prime',
      'correctNumbers': [13],
      'options': [12, 13, 14, 15, 16],
    },
    {
      'category': 'Composite',
      'correctNumbers': [12],
      'options': [11, 12, 13, 2, 7],
    },
    {
      'category': 'Square',
      'correctNumbers': [36],
      'options': [35, 36, 37, 38, 39],
    },
    {
      'category': 'Prime',
      'correctNumbers': [11],
      'options': [15, 10, 12, 11, 18],
    },
  ];

  int currentQuestionIndex = 0;
  List<int> draggedNumbers = [];
  String message = '';
  bool isCorrect = false;
  int score = 0;

  List<int> _getCorrectNumbers() => questions[currentQuestionIndex]['correctNumbers'];
  List<int> _getOptions() => questions[currentQuestionIndex]['options'];

  Future<void> checkAnswer() async {
    List<int> correctNumbers = _getCorrectNumbers();
    bool hasCorrectAnswer = draggedNumbers.any((n) => correctNumbers.contains(n));
    bool hasWrongAnswer = draggedNumbers.any((n) => !correctNumbers.contains(n));

    setState(() {
      if (hasCorrectAnswer && !hasWrongAnswer) {
        message = isEnglish ? "Correct! Well done":'¡Correcto! Bien hecho';
        isCorrect = true;
        score += 10; // Add points for correct answer
      } else {
        message = isEnglish ? "Try again": 'Inténtalo de nuevo';
        isCorrect = false;
        draggedNumbers.clear();
      }
    });

    // Voice feedback
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        draggedNumbers.clear();
        message = '';
        isCorrect = false;
      });
    } else {
      // Game completed - log completion with final score
      AnalyticsEngine.logGameComplete(gameType, score);
      print('Pattern Match Game completed with score: $score');
      
      setState(() {
        message = isEnglish ? 'You have completed all questions! Final score: $score' : '¡Has completado todas las preguntas! Puntaje final: $score';
        _confettiController.play();
      });
      _playCelebrationSound();
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    Future.delayed(Duration(seconds: 3), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(t('Game Over', 'Fin del Juego')),
            content: Text(t('Thanks for playing! Your final score is $score.', '¡Gracias por jugar! Tu puntaje final es $score.')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                  _audioPlayer.stop();                },
                child: Text(t('Play Again', 'Jugar de Nuevo')),
              ),
            ],
          );
        },
      );
    });
  }

  void _startNewGame() {
    setState(() {
      currentQuestionIndex = 0;
      draggedNumbers.clear();
      message = '';
      isCorrect = false;
      score = 0;
    });
    
    // Log new game start
    AnalyticsEngine.logGameStart(gameType);
    print('Pattern Match Game started');
  }

  void _playCelebrationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/celebration.mp3'));
    } catch (e) {
      print('Could not play celebration sound: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isTablet = size.width > 600;

  return Scaffold(
    appBar: AppBar(
      title: Text(t('Number Pattern Match', 'Coincidencia de Patrones Numéricos')),
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
            Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              t('Score: $score', 'Puntaje: $score'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
          ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
          // Game completed - log completion with final score
          AnalyticsEngine.logGameCompleteInMiddle();

        },
      ),
    ),
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Header info
              Text(
                t('Question ${currentQuestionIndex + 1} of ${questions.length}', 'Pregunta ${currentQuestionIndex + 1} de ${questions.length}'),
                style: GoogleFonts.lato(
                  fontSize: isTablet ? 22 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text( t('Category: ${questions[currentQuestionIndex]['category']}', 'Categoría: ${questions[currentQuestionIndex]['category']}'),
                style: GoogleFonts.lato(
                  fontSize: isTablet ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text( t('Score: $score', 'Puntaje: $score'),
                style: GoogleFonts.lato(
                  fontSize: isTablet ? 22 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Flexible Grid
              Expanded(
                flex: 4,
                child: GridView.count(
                  crossAxisCount: isTablet ? 5 : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                  children: _getOptions().map((number) {
                    return Draggable<int>(
                      data: number,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildOptionBox(number, isDragging: true),
                      ),
                      childWhenDragging: _buildOptionBox(number, faded: true),
                      child: _buildOptionBox(number),
                    );
                  }).toList(),
                ),
              ),

              // Drop Area
              Expanded(
                flex: 2,
                child: DragTarget<int>(
                  builder: (context, accepted, rejected) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: draggedNumbers.isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              children: draggedNumbers.map((n) {
                                return Chip(
                                  label: Text('$n',
                                      style: TextStyle(fontSize: 18)),
                                  backgroundColor: Colors.white,
                                );
                              }).toList(),
                            )
                          : Text(t('Drag numbers here', 'Arrastra los números aquí'),
                              style: GoogleFonts.lato(
                                fontSize: isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  onAccept: (n) {
                    setState(() {
                      if (!draggedNumbers.contains(n)) draggedNumbers.add(n);
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(t('Submit','enviar'), Colors.teal, checkAnswer, isTablet),
                  _buildButton(t('New Game','Nuevo Juego'), Colors.green, _startNewGame, isTablet),
                ],
              ),

              const SizedBox(height: 6),

              // Feedback + Next
              Text(
                message,
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildButton(t('Next Question','Siguiente pregunta"'), Colors.orange, nextQuestion, isTablet),

              _buildConfetti(),
            ],
          ),
        ),
      ),
    ),
  );
}


// Helper widget for options
Widget _buildOptionBox(int number, {bool isDragging = false, bool faded = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDragging
          ? Colors.blueAccent
          : faded
              ? Colors.grey
              : Colors.grey.shade50.withOpacity(0.7),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 28,
          color: isDragging ? Colors.white : faded ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// Helper widget for buttons
Widget _buildButton(String text, Color color, VoidCallback onPressed, bool isTablet) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 24 : 18,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}


  Widget _buildConfetti() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.03,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 5,
            gravity: 0.2,
            colors: const [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }
}