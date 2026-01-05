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
    _speak("Game reset", "Juego reiniciado");
  }

  void _nextRound() {
    setState(() {
      _message = '';
      _initNumbers();
    });
    _speak("New round", "Nueva ronda");
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
      appBar: AppBar(
        title: Text(
          t('Drag and Drop Perfect Squares', 'Arrastra y suelta los cuadrados perfectos'),
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
              style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
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
          Positioned.fill(
            child: Image.asset('assets/background1.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t('Find and drop the perfect squares!', 
                      '¡Encuentra y suelta los cuadrados perfectos!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),

                  SizedBox(height: 8),
                  Text(
                    '${t("Score", "Puntuación")}: $_score',
                    style: TextStyle(fontSize: 18),
                  ),

                  SizedBox(height: 10),

                  // 👉 NO CHANGES HERE
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 650),
                        child: GridView.builder(
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: _numbers.length,
                          itemBuilder: (_, i) {
                            final n = _numbers[i];
                            return Draggable<int>(
                              data: n,
                              feedback: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(10),
                                child: _NumberTile(n: n, elevated: true),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.2,
                                child: _NumberTile(n: n),
                              ),
                              child: _NumberTile(n: n),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: _message.isEmpty ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      _message,
                      style: TextStyle(
                        fontSize: 18,
                        color: _messageColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  DragTarget<int>(
                    onWillAccept: (data) {
                      setState(() => _isHoveringDrop = true);
                      return true;
                    },
                    onLeave: (_) {
                      setState(() => _isHoveringDrop = false);
                    },
                    onAccept: (data) {
                      setState(() => _isHoveringDrop = false);
                      _handleAccept(data);
                    },
                    builder: (_, __, ___) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: 120,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8, bottom: 4),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: (_isHoveringDrop
                                  ? Colors.greenAccent
                                  : Colors.greenAccent.withOpacity(0.85))
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white,
                            width: _isHoveringDrop ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_rounded, size: 28, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                t('Drop perfect squares here', 
                                  'Suelta los cuadrados perfectos aquí'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _resetGame,
                        icon: Icon(Icons.refresh),
                        label: Text(t('Reset', 'Reiniciar')),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _nextRound,
                        icon: Icon(Icons.play_arrow),
                        label: Text(t('Next Round', 'Siguiente ronda')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final int n;
  final bool elevated;

  const _NumberTile({required this.n, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: elevated
            ? [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]
            : [
                BoxShadow(color: Colors.black12, blurRadius: 3)
              ],
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
