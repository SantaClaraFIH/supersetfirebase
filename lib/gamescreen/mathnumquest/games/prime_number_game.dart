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

class _PrimeNumberGridState extends State<PrimeNumberGrid>
    with TickerProviderStateMixin {
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  final List<int> numbers = [];
  final List<int> selectedIndices = [];
  bool showResult = false;
  bool? isCorrect;
  String feedback = '';

  late FlutterTts _tts;
  late ConfettiController _confettiController;
  final String gameType = 'prime_explorer';
  int totalScore = 0;
  int score = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _bounceController;

  // Rainbow color pairs for number tiles
  static const _tileColors = [
    [Color(0xFFF9A8B8), Color(0xFFF48FB1)],
    [Color(0xFFB2DFDB), Color(0xFF80CBC4)],
    [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
    [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
    [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
    [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
    [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
    [Color(0xFFFFECB3), Color(0xFFFFD54F)],
  ];

  // Floating decoration data
  final List<_FloatingDecor> _decorations = [];
  static const _decorEmojis = ['✨', '⭐', '🔢', '💎', '🌟', '🎯', '🧮', '💫'];

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

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initDecorations();
    generateRandomNumbers();
    AnalyticsEngine.logGameStart(gameType);
  }

  void _initDecorations() {
    final rng = Random();
    _decorations.clear();
    for (int i = 0; i < 18; i++) {
      _decorations.add(_FloatingDecor(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 16 + rng.nextDouble() * 20,
        speed: 0.5 + rng.nextDouble() * 1.5,
        emoji: _decorEmojis[rng.nextInt(_decorEmojis.length)],
      ));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _floatController.dispose();
    _bounceController.dispose();
    _tts.stop();
    super.dispose();
  }

  void generateRandomNumbers() {
    final random = Random();
    numbers.clear();
    while (numbers.length < 16) {
      final n = random.nextInt(50) + 1;
      if (!numbers.contains(n)) numbers.add(n);
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
          ? t('Awesome! You got it! 🎉', '¡Increíble! ¡Lo lograste! 🎉')
          : t('Not quite! Try again! 💪', '¡Casi! ¡Inténtalo de nuevo! 💪');

      if (correct) {
        score += 10;
        totalScore += 10;
      }
    });

    if (correct) {
      _confettiController.play();
      _bounceController.forward(from: 0);
      await _speak(
        "Awesome! You got it right!",
        "¡Increíble! ¡Lo lograste!",
      );
    } else {
      await _speak(
        'Not quite! Keep trying!',
        '¡Casi! ¡Sigue intentando!',
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
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8A65), Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              t('Prime Explorer', 'Explorador de Primos'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  isEnglish = !isEnglish;
                  _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
                });
                AnalyticsEngine.logGameTranslateButtonClick();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              child: Text(
                isEnglish ? '🌐 ES' : '🌐 EN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
            AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F0),
              Color(0xFFFFF0E6),
              Color(0xFFFCE4EC),
              Color(0xFFF3E5F5),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Radial glow top-right
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Radial glow bottom-left
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating decorations
            ..._decorations.map((d) {
              return AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: d.x * MediaQuery.of(context).size.width,
                    top: d.y * MediaQuery.of(context).size.height +
                        _floatAnimation.value * d.speed,
                    child: Opacity(
                      opacity: 0.35,
                      child: Text(
                        d.emoji,
                        style: TextStyle(fontSize: d.size),
                      ),
                    ),
                  );
                },
              );
            }),
            // Main content
            SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                    const SizedBox(height: 4),
                    // Instruction + Score row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Instruction
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🎯', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    t('Tap all the prime numbers!',
                                      '¡Toca todos los números primos!'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF37474F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Score badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFFB74D)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB74D).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '$score',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Feedback area
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: feedback.isEmpty ? 0.0 : 1.0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCorrect == true
                              ? const Color(0xFF00C853).withOpacity(0.15)
                              : const Color(0xFFFF5252).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCorrect == true
                                ? const Color(0xFF00C853).withOpacity(0.4)
                                : const Color(0xFFFF5252).withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isCorrect == true
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFFB71C1C),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Number tiles - 4x4 grid
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: numbers.length,
                            itemBuilder: (context, index) {
                              final value = numbers[index];
                              final selected = selectedIndices.contains(index);
                              final colorPair = _tileColors[index % _tileColors.length];

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
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutBack,
                                  transform: Matrix4.identity()
                                    ..scale(selected ? 1.08 : 1.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: selected
                                          ? [const Color(0xFFFFE082), const Color(0xFFFFCA28)]
                                          : [colorPair[0], colorPair[1]],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFFFFB300)
                                          : Colors.white.withOpacity(0.7),
                                      width: selected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (selected
                                                ? const Color(0xFFFFCA28)
                                                : colorPair[0])
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (selected)
                                          const Text('✅', style: TextStyle(fontSize: 12)),
                                        Text(
                                          '$value',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: selected
                                                ? const Color(0xFF5D4037)
                                                : const Color(0xFF37474F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          onTap: checkResult,
                        ),
                        _buildActionButton(
                          emoji: '⏭️',
                          label: t('Next', 'Siguiente'),
                          colors: [const Color(0xFF448AFF), const Color(0xFF82B1FF)],
                          onTap: nextRound,
                        ),
                        _buildActionButton(
                          emoji: '🔄',
                          label: t('Reset', 'Reiniciar'),
                          colors: [const Color(0xFFFF6D00), const Color(0xFFFFAB40)],
                          onTap: resetBoard,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              ),
            ),
            // Confetti
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
      ),
    );
  }
}

class _FloatingDecor {
  final double x, y, size, speed;
  final String emoji;
  const _FloatingDecor({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.emoji,
  });
}