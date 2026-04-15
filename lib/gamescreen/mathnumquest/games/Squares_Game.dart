import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart';

void main() {
  runApp(PerfectSquareFinder());
}

class PerfectSquareFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SquareFinderGame(),
    );
  }
}

class SquareFinderGame extends StatefulWidget {
  final bool isEnglish;
  const SquareFinderGame({super.key, this.isEnglish = true});

  @override
  State<SquareFinderGame> createState() => _SquareFinderGameState();
}

class _SquareFinderGameState extends State<SquareFinderGame> {
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  late FlutterTts _tts;
  late ConfettiController _confetti;

  final String gameType = 'perfect_square';

  final List<int> _perfectSquares = [1, 4, 9, 16, 25];
  final List<int> _numbers = [];
  final List<int> _collected = [];

  int _score = 0;
  int totalScore = 0;

  String _message = '';
  Color _messageColor = Colors.black87;
  bool _isHoveringDrop = false;

  @override
  void initState() {
    super.initState();

    isEnglish = widget.isEnglish;

    _tts = FlutterTts();
    _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
    _tts.setSpeechRate(0.5);

    _confetti = ConfettiController(duration: Duration(seconds: 1));

    _initNumbers();
    AnalyticsEngine.logGameStart(gameType);
  }

  Future<void> _speak(String en, String es) async {
    await _tts.stop();
    await _tts.speak(isEnglish ? en : es);
  }

  void _initNumbers() {
    _numbers.clear();
    _numbers.addAll(_perfectSquares);

    final rnd = Random();
    while (_numbers.length < 20) {
      final n = rnd.nextInt(30) + 1;
      if (!_numbers.contains(n)) _numbers.add(n);
    }
    _numbers.shuffle();
  }

  bool _isPerfectSquare(int n) {
    final r = sqrt(n).toInt();
    return r * r == n;
  }

  void _handleAccept(int number) {
    if (_isPerfectSquare(number)) {
      setState(() {
        _collected.add(number);
        _numbers.remove(number);
        _score++;
        totalScore += 10;

        _message = t('Correct! Well done', '¡Correcto! Bien hecho');
        _messageColor = Colors.green.shade700;
      });

      _speak("Correct! Well done", "¡Correcto! Bien hecho");
      _confetti.play();

      if (_collected.length == _perfectSquares.length) {
        AnalyticsEngine.logGameComplete(gameType, totalScore);

        setState(() {
          _message = t(
            'You have completed all questions! Final score: $totalScore',
            '¡Has completado todas las preguntas! Puntuación final: $totalScore',
          );
        });

        _showGameOverDialog();
      }
    } else {
      setState(() {
        _message = t('Try again', 'Inténtalo de nuevo');
        _messageColor = Colors.red.shade700;
      });

      _speak("Try again", "Inténtalo de nuevo");
    }
  }

  void _showGameOverDialog() {
    Future.delayed(Duration(seconds: 2), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t('Game Complete!', '¡Juego completado!')),
          content: Text(
            t(
              'Congratulations!\nFinal Score: $totalScore points',
              '¡Felicidades!\nPuntuación final: $totalScore puntos',
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: _resetGame,
              icon: Icon(Icons.refresh),
              label: Text(t('Play Again', 'Jugar de Nuevo')),
            ),
          ],
        ),
      );
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      totalScore = 0;
      _message = '';
      _collected.clear();
      _numbers.clear();
    });

    _initNumbers();
    AnalyticsEngine.logGameStart(gameType);
  }

  void _nextRound() {
    setState(() {
      _message = '';
      _initNumbers();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          t('Perfect Squares', 'Cuadrados Perfectos'),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
                _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
              });
              AnalyticsEngine.logGameTranslateButtonClick();
            },
            child: Text(
              isEnglish ? "Translate to Spanish" : "Traducir al inglés",
              style: TextStyle(color: Colors.orange,fontSize: 14,fontWeight: FontWeight.w600),
            ),
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF48A9FE),
              Color(0xFF78D5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [

                /// HEADER
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t('Drag perfect squares into the box',
                        'Arrastra cuadrados perfectos'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                SizedBox(height: 12),

                /// SCORE
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Score:$_score',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                SizedBox(height: 16),

                /// GRID (ORIGINAL SIZE RESTORED)
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 650),
                      child: GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _numbers.length,
                        itemBuilder: (_, i) {
                          final n = _numbers[i];
                          return Draggable<int>(
                            data: n,
                            feedback: Material(
                              child: _NumberTile(n: n, elevated: true),
                            ),
                            childWhenDragging:
                                Opacity(opacity: 0.2, child: _NumberTile(n: n)),
                            child: _NumberTile(n: n),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                if (_message.isNotEmpty)
                  Text(
                    _message,
                    style: TextStyle(
                      color: _messageColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                SizedBox(height: 10),

                /// DROP ZONE
                DragTarget<int>(
                  onAccept: _handleAccept,
                  builder: (_, __, ___) => Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        t('Drop here', 'Suelta aquí'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        //fontSize: 18,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                /// BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: _resetGame, child: Text(t('Reset', 'Reiniciar'))),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: _nextRound, child: Text(t('Next', 'Siguiente'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: ConfettiWidget(
        confettiController: _confetti,
        blastDirectionality: BlastDirectionality.explosive,
      ),
    );
  }
}

/// ORIGINAL TILE UI (RESTORED)
class _NumberTile extends StatelessWidget {
  final int n;
  final bool elevated;

  const _NumberTile({required this.n, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: elevated
            ? [BoxShadow(color: Colors.black26, blurRadius: 6)]
            : [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Center(
        child: Text(
          '$n',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}