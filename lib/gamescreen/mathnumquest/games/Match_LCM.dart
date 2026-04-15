import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart';

void main() => runApp(LCMGame());

class LCMGame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LCM Matching Game",
      home: LCMGamePage(), 
    );
  }
}

class LCMGamePage extends StatefulWidget {
  final bool isEnglish; 

  const LCMGamePage({Key? key, this.isEnglish = true}) : super(key: key);

  @override
  _LCMGamePageState createState() => _LCMGamePageState();
}

class _LCMGamePageState extends State<LCMGamePage> {
  late List<ItemModel> items;
  late List<ItemModel> items2;
  late List<ItemModel> initialItems;
  late List<ItemModel> initialItems2;

  late int score;
  late bool gameOver;
  final String gameType = 'lcm_match';
  int totalScore = 0;
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  late FlutterTts flutterTts;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;
    flutterTts = FlutterTts();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    initGame();
    
    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  // Pool of possible number pairs for variety
  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % t;
      a = t;
    }
    return a;
  }

  static int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);

  void initGame() {
    gameOver = false;
    score = 0;

    final rng = Random();
    final usedLcms = <int>{};
    final pairs = <List<int>>[];

    // Generate 5 unique pairs with distinct LCM values
    while (pairs.length < 5) {
      final a = rng.nextInt(18) + 2; // 2–19
      final b = rng.nextInt(18) + 2; // 2–19
      if (a == b) continue;
      final lcm = _lcm(a, b);
      if (lcm > 100) continue; // keep LCM kid-friendly
      if (usedLcms.contains(lcm)) continue;
      usedLcms.add(lcm);
      pairs.add([a, b, lcm]);
    }

    items = pairs
        .map((p) => ItemModel(name: "${p[0]} and ${p[1]}", value: "${p[2]}"))
        .toList();
    items2 = pairs
        .map((p) => ItemModel(name: "${p[2]}", value: "${p[2]}"))
        .toList();

    // Save original lists for Reset
    initialItems = List.from(items);
    initialItems2 = List.from(items2);

    items.shuffle();
    items2.shuffle();
    setState(() {});
  }

  void resetGame() {
    setState(() {
      items = List.from(initialItems);
      items2 = List.from(initialItems2);
      score = 0;
      gameOver = false;
    });
  }

  void newGame() {
    initGame();
    // Log new game start
    AnalyticsEngine.logGameStart(gameType);
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void handleMatch(ItemModel topItem, ItemModel bottomItem) {
    if (topItem.value == bottomItem.value) {
      setState(() {
        items.remove(topItem);
        items2.remove(bottomItem);
        score += 10;
        totalScore += 10; // Add to total score for analytics
        speak(isEnglish? "Correct! Well done!": "¡Correcto! ¡Bien hecho!");
        _confettiController.play();
        
        if (items.isEmpty) {
          gameOver = true;
          // Log game completion with final score
          AnalyticsEngine.logGameComplete(gameType, totalScore);
        }
      });
    } else {
      setState(() {
        score -= 5;
        totalScore -= 5; // Subtract from total score for analytics
        speak(isEnglish? "Oops! Try again!": "¡Ups! ¡Inténtalo de nuevo!");
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB39DDB), Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔗', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              t('LCM Match', 'MCM Match'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  isEnglish = !isEnglish;
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
                isEnglish ? 'Tap to Translate' : 'Toca para Traducir',
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
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAF3FF),
              Color(0xFFF3E5F5),
              Color(0xFFFCE4EC),
              Color(0xFFFFF8E1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glowing orbs
            Positioned(
              top: screenHeight * 0.15,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCE93D8).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.1,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF90CAF9).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.5,
              right: 20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFCC80).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue, Colors.white70],
              gravity: 0.3,
            ),
            SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      // Instruction + Score + Progress row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.6)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFCE93D8).withOpacity(0.08),
                                    blurRadius: 10,
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
                                      t('Drag the LCM to its pair!',
                                        '¡Arrastra el MCM a su par!'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF37474F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFE082), Color(0xFFFFB74D)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFFFCC80), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB74D).withOpacity(0.3),
                                  blurRadius: 12,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Main game area - side by side in glass cards
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column - Number Pairs (targets)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFD1C4E9).withOpacity(0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB39DDB).withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB39DDB).withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        t('📝 Pairs', '📝 Pares'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF4A148C),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...items.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: DragTarget<ItemModel>(
                                          onAccept: (receivedItem) =>
                                              handleMatch(item, receivedItem),
                                          builder: (context, accepted, rejected) {
                                            final hovering = accepted.isNotEmpty;
                                            return AnimatedContainer(
                                              duration: const Duration(milliseconds: 250),
                                              height: 60,
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..scale(hovering ? 1.05 : 1.0),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: hovering
                                                      ? [const Color(0xFFCE93D8), const Color(0xFFBA68C8)]
                                                      : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: hovering
                                                      ? const Color(0xFFBA68C8)
                                                      : const Color(0xFFB39DDB).withOpacity(0.4),
                                                  width: hovering ? 2.5 : 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFB39DDB).withOpacity(hovering ? 0.45 : 0.12),
                                                    blurRadius: hovering ? 20 : 8,
                                                    spreadRadius: hovering ? 3 : 0,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  if (hovering)
                                                    const Padding(
                                                      padding: EdgeInsets.only(right: 6),
                                                      child: Text('🎯', style: TextStyle(fontSize: 14)),
                                                    ),
                                                  Text(
                                                    item.name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: hovering ? Colors.white : const Color(0xFF4A148C),
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Right column - LCM Answers (draggables)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFB2DFDB).withOpacity(0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF80CBC4).withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFB2DFDB), Color(0xFF80CBC4)],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF80CBC4).withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        t('🧮 LCM', '🧮 MCM'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF004D40),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...items2.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Draggable<ItemModel>(
                                          data: item,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              height: 60,
                                              width: 130,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF80CBC4).withOpacity(0.5),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 22,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Container(
                                            height: 60,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0F2F1).withOpacity(0.4),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: const Color(0xFF80CBC4).withOpacity(0.25),
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text('👻', style: TextStyle(fontSize: 22)),
                                          ),
                                          child: Container(
                                            height: 60,
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFFE0F2F1),
                                                  const Color(0xFFB2DFDB),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: const Color(0xFF80CBC4).withOpacity(0.4),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF80CBC4).withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned(
                                                  right: 8,
                                                  child: Icon(
                                                    Icons.drag_indicator_rounded,
                                                    color: const Color(0xFF80CBC4).withOpacity(0.4),
                                                    size: 18,
                                                  ),
                                                ),
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    color: Color(0xFF004D40),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                            emoji: '🔄',
                            label: t('Reset', 'Reiniciar'),
                            colors: [const Color(0xFFB39DDB), const Color(0xFF9575CD)],
                            onTap: resetGame,
                          ),
                          _buildActionButton(
                            emoji: '✨',
                            label: t('New Game', 'Nuevo'),
                            colors: [const Color(0xFF80CBC4), const Color(0xFF4DB6AC)],
                            onTap: newGame,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (gameOver)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCE93D8), Color(0xFFF48FB1)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCE93D8).withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            t('🎉 Great Job! All Matched! 🎉',
                              '🎉 ¡Buen Trabajo! ¡Todo Emparejado! 🎉'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemModel {
  final String name;
  final String value;

  ItemModel({required this.name, required this.value});
}