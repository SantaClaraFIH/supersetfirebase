import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart'; // Import analytics engine

void main() => runApp(MaterialApp(home: PerfectSquareFinder()));

/**class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Game'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfectSquareFinder()),
            );
          },
        ),
      ),
    );
  }
}*/

class PerfectSquareFinder extends StatelessWidget {
  const PerfectSquareFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drag and Drop Perfect Squares', style: TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Log game completion with final score
            AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),
      body: const SquareFinderGame(),
    );
  }
}

class SquareFinderGame extends StatefulWidget {
  const SquareFinderGame({super.key});

  @override
  State<SquareFinderGame> createState() => _SquareFinderGameState();
}

class _SquareFinderGameState extends State<SquareFinderGame> {
  late FlutterTts _tts;
  late ConfettiController _confetti;
  final String gameType = 'perfect_square'; // Define game type

  final List<int> _perfectSquares = [1, 4, 9, 16, 25];
  final List<int> _numbers = [];
  final List<int> _collected = [];

  int _score = 0;
  String _message = '';
  Color _messageColor = Colors.black87;
  int totalScore = 0; // Track total score for analytics

  bool _isHoveringDrop = false;

  @override
  void initState() {
    super.initState();

    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);

    _confetti = ConfettiController(duration: const Duration(seconds: 1));

    _initNumbers();
    
    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
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

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _handleAccept(int number) {
    if (_isPerfectSquare(number)) {
      setState(() {
        _collected.add(number);
        _numbers.remove(number);
        _score++;
        totalScore += 10; // Add to total score for analytics
        _message = 'Correct! Well done';
        _messageColor = Colors.green.shade700;
      });
      _speak('Correct! Well done');
      _confetti.play();
      
      // Check if all perfect squares are collected
      if (_collected.length == _perfectSquares.length) {
        // Log game completion with final score
        AnalyticsEngine.logGameComplete(gameType, totalScore);
        setState(() {
        _message = 'You have completed all questions! Final score: $totalScore';
       // _confettiController.play();
      });
      _showGameOverDialog();
      }
    } else {
      setState(() {
        _message = 'Oops! Try again';
        _messageColor = Colors.red.shade700;
      });
      _speak('Oops! Try again');
    }
  }

void _showGameOverDialog() {
    Future.delayed(Duration(seconds: 3), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Complete!'),
            content: Text('Congratulations!\nFinal Score: $totalScore points'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Play Again'),
              ),
            ],
          );
        },
      );
    });
  }
  void _resetGame() {
    setState(() {
      _collected.clear();
      _score = 0;
      totalScore = 0; // Reset total score
      _message = '';
      _initNumbers();
    });
    
    // Log new game start
    AnalyticsEngine.logGameStart(gameType);
    _speak('Game reset');
  }

  void _nextRound() {
    setState(() {
      _message = '';
      _initNumbers();
    });
    _speak('New round');
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/MathNumQuest/background1.jpg',
            fit: BoxFit.cover,
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Find and drop the perfect squares!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $_score',
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _message,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _messageColor,
                      ),
                    ),
                  ),
                ),

                DragTarget<int>(
                  onWillAccept: (data) {
                    setState(() => _isHoveringDrop = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => _isHoveringDrop = false);
                  },
                  onAccept: (data) {
                    setState(() => _isHoveringDrop = false);
                    _handleAccept(data);
                  },
                  builder: (context, accepted, rejected) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 120,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.inbox_rounded,
                                size: 28, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Drop perfect squares here',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _nextRound,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Next Round'),
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
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.7,
          ),
        ),
      ],
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
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: elevated
            ? const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]
            : const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Center(
        child: Text(
          '$n',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}