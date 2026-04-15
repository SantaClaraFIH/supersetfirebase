import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart';

// Floating decoration data
class _Bubble {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final Color borderColor;
  final String shape; // 'circle', 'star', 'cloud', 'ring'
  _Bubble({required this.x, required this.y, required this.size, required this.speed, required this.color, required this.borderColor, required this.shape});
}

void main() {
  runApp(EvenOddSortApp());
}

class EvenOddSortApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Even Odd Sort',
      home: EvenOddSortPage(),
    );
  }
}

class EvenOddSortPage extends StatefulWidget {
  final bool isEnglish;
  const EvenOddSortPage({Key? key, this.isEnglish = true}) : super(key: key);

  @override
  _EvenOddSortPageState createState() => _EvenOddSortPageState();
}

class _EvenOddSortPageState extends State<EvenOddSortPage>
    with TickerProviderStateMixin {
  List<int> evenNumbers = [];
  List<int> oddNumbers = [];
  List<int> bottomNumbers = List.generate(6, (index) => Random().nextInt(20) + 1);
  List<int> initialBottomNumbers = [];
  bool? isCorrect;
  int score = 0;
  late FlutterTts flutterTts;
  late ConfettiController confettiController;
  final String gameType = 'even_odd_sort';
  int totalScore = 0;
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;
  bool _evenHover = false;
  bool _oddHover = false;

  static const _decorShapes = ['circle', 'star', 'cloud', 'ring', 'star', 'circle'];

  final List<_Bubble> _bubbles = List.generate(22, (i) {
    final rng = Random();
    final colors = [
      [const Color(0x40FFFFFF), const Color(0x30FFFFFF)],
      [const Color(0x35FFD54F), const Color(0x25FFAB40)],
      [const Color(0x35FF80AB), const Color(0x25F48FB1)],
      [const Color(0x3580DEEA), const Color(0x2540C4FF)],
      [const Color(0x35CE93D8), const Color(0x25AB47BC)],
      [const Color(0x35A5D6A7), const Color(0x2566BB6A)],
      [const Color(0x35FFE082), const Color(0x25FFD54F)],
    ];
    final pick = colors[rng.nextInt(colors.length)];
    return _Bubble(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 40 + 16,
      speed: rng.nextDouble() * 0.5 + 0.2,
      color: pick[0],
      borderColor: pick[1],
      shape: _decorShapes[rng.nextInt(_decorShapes.length)],
    );
  });

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;
    flutterTts = FlutterTts();
    confettiController = ConfettiController(duration: Duration(seconds: 2));
    initialBottomNumbers = List.from(bottomNumbers);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.bounceOut,
    ));

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation =
        Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _wiggleAnimation =
        Tween<double>(begin: -0.03, end: 0.03).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.easeInOut,
    ));

    AnalyticsEngine.logGameStart(gameType);
  }

  @override
  void dispose() {
    confettiController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  String numberToText(int number) {
    const List<String> units = [
      'zero', 'one', 'two', 'three', 'four', 'five',
      'six', 'seven', 'eight', 'nine', 'ten',
      'eleven', 'twelve', 'thirteen', 'fourteen',
      'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'
    ];
    const List<String> tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty',
      'sixty', 'seventy', 'eighty', 'ninety'
    ];

    if (number < 20) return units[number];
    if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? ' ${units[number % 10]}' : '');
    }
    return number.toString();
  }

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  void checkNumbers() {
    bool allEvenSorted = evenNumbers.every((number) => number.isEven);
    bool allOddSorted = oddNumbers.every((number) => !number.isEven);

    isCorrect = allEvenSorted && allOddSorted && bottomNumbers.isEmpty;

    if (isCorrect == true) {
      score += 10;
      totalScore += 10;
      speak(isEnglish
          ? "Awesome! You're doing great! Keep it up!"
          : '¡Increíble! ¡Lo estás haciendo genial! ¡Sigue así!');
      confettiController.play();
    } else {
      speak(isEnglish ? "Almost! You can do it! Try again!" : '¡Casi! ¡Tú puedes! ¡Inténtalo de nuevo!');
    }

    setState(() {});
  }

  void newGame() {
    setState(() {
      evenNumbers.clear();
      oddNumbers.clear();
      bottomNumbers = List.generate(6, (index) => Random().nextInt(20) + 1);
      initialBottomNumbers = List.from(bottomNumbers); 
      isCorrect = null; 
    });
    
    // Log new game start
    AnalyticsEngine.logGameStart(gameType);
  }

  void resetGame() {
    setState(() {
      evenNumbers.clear();
      oddNumbers.clear();
      bottomNumbers = List.from(initialBottomNumbers);
      isCorrect = null;
    });
  }

  // Method to end game and log completion (can be called when user decides to finish)
  void endGame() {
    AnalyticsEngine.logGameComplete(gameType, totalScore);
  }

  Widget buildDragTarget(String label, String emoji, List<Color> gradientColors, IconData icon, List<int> numbersList, bool isHovering, void Function(bool) onHover) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hovering != isHovering) onHover(hovering);
        });
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          width: hovering ? 178 : 168,
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withOpacity(0.85),
                gradientColors[1].withOpacity(0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: hovering
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
              width: hovering ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(hovering ? 0.55 : 0.25),
                blurRadius: hovering ? 35 : 20,
                spreadRadius: hovering ? 4 : 0,
                offset: const Offset(0, 10),
              ),
              // Top highlight for 3D effect
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouncing emoji mascot
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value * 0.5),
                    child: Transform.scale(
                      scale: hovering ? 1.2 : 1.0,
                      child: child,
                    ),
                  );
                },
                child: Text(emoji, style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(height: 8),
              // Label with glow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (numbersList.isEmpty)
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.5 + (_floatAnimation.value + 8) / 32,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        hovering ? Icons.file_download_rounded : Icons.arrow_downward_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hovering
                            ? t('Let go!', '¡Suelta!')
                            : t('Drop here', 'Soltar aquí'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: numbersList.map((n) {
                    final chipColor = _numberColors[n % _numberColors.length];
                    return GestureDetector(
                      onTap: () {
                        // Tap to remove from bucket and send back to bottom
                        setState(() {
                          numbersList.remove(n);
                          if (!bottomNumbers.contains(n)) {
                            bottomNumbers.add(n);
                          }
                        });
                      },
                      child: Draggable<int>(
                      data: n,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [chipColor[0], chipColor[1]],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: chipColor[0].withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      onDraggableCanceled: (_, __) {
                        // Dropped outside any target — send back to bottom
                        setState(() {
                          numbersList.remove(n);
                          if (!bottomNumbers.contains(n)) {
                            bottomNumbers.add(n);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [chipColor[0].withOpacity(0.6), chipColor[1].withOpacity(0.4)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: Text(
                          '$n',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
      onAccept: (number) {
        setState(() {
          // Remove from other bucket if it was there
          if (numbersList == evenNumbers) {
            oddNumbers.remove(number);
          } else {
            evenNumbers.remove(number);
          }
          bottomNumbers.remove(number);
          if (!numbersList.contains(number)) {
            numbersList.add(number);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.7),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _wiggleController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _wiggleAnimation.value * 2,
                  child: child,
                );
              },
              child: const Text('🔢', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 8),
            Text(
              t("Even & Odd Sort", "Pares e Impares"),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
              });
              AnalyticsEngine.logGameTranslateButtonClick();
            },
            icon: const Icon(Icons.translate, color: Colors.orangeAccent),
            label: Text(
              isEnglish ? "ES" : "EN",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            endGame();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF48A9FE),
              Color(0xFF78D5F5),
              Color(0xFFD4FC79),
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Soft radial glow top-right
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF80AB).withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Soft radial glow bottom-left
              Positioned(
                bottom: -40,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD54F).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Wave decoration at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 80),
                      painter: _WavePainter(
                        animValue: _floatAnimation.value,
                        color1: Colors.white.withOpacity(0.12),
                        color2: Colors.white.withOpacity(0.06),
                      ),
                    );
                  },
                ),
              ),
              // Floating decorations
              ..._bubbles.map((b) {
                return AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final dy = _floatAnimation.value * b.speed * 14;
                    return Positioned(
                      left: b.x * MediaQuery.of(context).size.width,
                      top: b.y * MediaQuery.of(context).size.height + dy,
                      child: Transform.rotate(
                        angle: _floatAnimation.value * 0.06 * b.speed,
                        child: _buildDecoration(b),
                      ),
                    );
                  },
                );
              }),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Header instruction with bounce
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value * 0.3),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF48A9FE)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('🎮', style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                t("Drag each number into the right bucket!",
                                  "¡Arrastra cada número al balde correcto!"),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF37474F),
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB74D)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB74D).withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Drag targets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: buildDragTarget(
                            t('EVEN', 'PARES'),
                            '🐸',
                            [const Color(0xFF00C853), const Color(0xFF69F0AE)],
                            Icons.looks_two_rounded,
                            evenNumbers,
                            _evenHover,
                            (v) => setState(() => _evenHover = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: buildDragTarget(
                            t('ODD', 'IMPARES'),
                            '🦋',
                            [const Color(0xFF7C4DFF), const Color(0xFFB388FF)],
                            Icons.looks_one_rounded,
                            oddNumbers,
                            _oddHover,
                            (v) => setState(() => _oddHover = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Draggable number chips (wrapped in DragTarget to accept returns)
                    DragTarget<int>(
                      builder: (context, candidateData, rejectedData) {
                        final hovering = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(hovering ? 12 : 0),
                          decoration: hovering
                              ? BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                )
                              : null,
                          child: bottomNumbers.isNotEmpty
                              ? Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: bottomNumbers.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final number = entry.value;
                          return AnimatedBuilder(
                            animation: _wiggleController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _wiggleAnimation.value * (idx.isEven ? 1 : -1),
                                child: child,
                              );
                            },
                            child: Draggable<int>(
                              data: number,
                              child: buildNumberBox(number),
                              feedback: Material(
                                color: Colors.transparent,
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: buildNumberBox(number, dragging: true),
                                ),
                              ),
                              childWhenDragging: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 2.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text('👻', style: TextStyle(fontSize: 30)),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          t('All sorted! Tap Check ✅',
                            '¡Todo listo! Toca Verificar ✅'),
                          style: const TextStyle(
                            color: Color(0xFF37474F),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                        );
                      },
                      onAccept: (number) {
                        setState(() {
                          evenNumbers.remove(number);
                          oddNumbers.remove(number);
                          if (!bottomNumbers.contains(number)) {
                            bottomNumbers.add(number);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildActionButton(
                          emoji: '✅',
                          label: t('Check', 'Verificar'),
                          colors: [const Color(0xFF00C853), const Color(0xFF69F0AE)],
                          onTap: checkNumbers,
                        ),
                        _buildActionButton(
                          emoji: '🔄',
                          label: t('Reset', 'Reiniciar'),
                          colors: [const Color(0xFFFF6D00), const Color(0xFFFFAB40)],
                          onTap: resetGame,
                        ),
                        _buildActionButton(
                          emoji: '⏭️',
                          label: t('Next', 'Siguiente'),
                          colors: [const Color(0xFF6C63FF), const Color(0xFFB388FF)],
                          onTap: newGame,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Feedback message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isCorrect != null
                          ? Container(
                              key: ValueKey(isCorrect),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isCorrect! ? const Color(0xFF66BB6A) : const Color(0xFFFF8A65),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isCorrect! ? const Color(0xFF66BB6A) : const Color(0xFFFF8A65)).withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isCorrect! ? '🎉' : '💪',
                                    style: const TextStyle(fontSize: 34),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isCorrect!
                                              ? t('Yay! Great job!', '¡Genial! ¡Buen trabajo!')
                                              : t('Almost there!', '¡Casi lo logras!'),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isCorrect!
                                              ? t('You\'re doing great! Keep going! 🎉', '¡Lo estás haciendo genial! 🎉')
                                              : t('You can do it! Try again! 🔄', '¡Tú puedes! ¡Otra vez! 🔄'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isCorrect! ? const Color(0xFF388E3C) : const Color(0xFFBF360C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.06,
                  numberOfParticles: 20,
                  maxBlastForce: 30,
                  minBlastForce: 10,
                  gravity: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String emoji,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _numberColors = [
    [Color(0xFFEF5350), Color(0xFFFF8A80)],  // red
    [Color(0xFFFF7043), Color(0xFFFFAB91)],  // orange
    [Color(0xFFFFCA28), Color(0xFFFFE082)],  // yellow
    [Color(0xFF66BB6A), Color(0xFFA5D6A7)],  // green
    [Color(0xFF42A5F5), Color(0xFF90CAF9)],  // blue
    [Color(0xFFAB47BC), Color(0xFFE1BEE7)],  // purple
  ];

  Widget buildNumberBox(int number, {bool dragging = false}) {
    final colorPair = _numberColors[number % _numberColors.length];
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withOpacity(dragging ? 0.6 : 0.3),
            blurRadius: dragging ? 24 : 14,
            spreadRadius: dragging ? 3 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$number",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Text(
            numberToText(number),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoration(_Bubble b) {
    if (b.shape == 'star') {
      return Text(
        '✨',
        style: TextStyle(fontSize: b.size * 0.7),
      );
    } else if (b.shape == 'cloud') {
      return Text(
        '☁️',
        style: TextStyle(fontSize: b.size * 0.65),
      );
    } else if (b.shape == 'ring') {
      return Container(
        width: b.size,
        height: b.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: b.borderColor, width: 2.5),
        ),
      );
    }
    // Glassmorphic circle
    return Container(
      width: b.size,
      height: b.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            b.color,
            b.color.withOpacity(0.05),
          ],
          stops: const [0.3, 1.0],
        ),
        border: Border.all(color: b.borderColor, width: 1.5),
      ),
    );
  }
}

// Wave painter for bottom decoration
class _WavePainter extends CustomPainter {
  final double animValue;
  final Color color1;
  final Color color2;

  _WavePainter({required this.animValue, required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;
    final shift = animValue * 8;

    // First wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.5 + shift);
    path1.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2 + shift,
      size.width * 0.5, size.height * 0.45 + shift,
    );
    path1.quadraticBezierTo(
      size.width * 0.75, size.height * 0.7 + shift,
      size.width, size.height * 0.35 + shift,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.65 - shift * 0.5);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.4 - shift * 0.5,
      size.width * 0.6, size.height * 0.6 - shift * 0.5,
    );
    path2.quadraticBezierTo(
      size.width * 0.85, size.height * 0.8 - shift * 0.5,
      size.width, size.height * 0.5 - shift * 0.5,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}