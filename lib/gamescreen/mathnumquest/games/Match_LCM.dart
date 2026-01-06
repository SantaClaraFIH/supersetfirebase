import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:supersetfirebase/gamescreen/mathnumquest/game_list_page.dart';
import '../analytics_engine.dart'; // Import analytics engine

void main() => runApp(LCMGame());

class LCMGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LCM Matching Game",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<ItemModel> items;
  late List<ItemModel> items2;
  late List<ItemModel> initialItems;
  late List<ItemModel> initialItems2;

  late int score;
  late bool gameOver;
  final String gameType = 'lcm_match'; // Define game type
  int totalScore = 0; // Track total score for analytics

  late FlutterTts flutterTts;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    initGame();
    
    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  void initGame() {
    gameOver = false;
    score = 0;

    items = [
      ItemModel(name: "12 and 8", value: "24"),
      ItemModel(name: "18 and 9", value: "18"),
      ItemModel(name: "20 and 5", value: "20"),
      ItemModel(name: "15 and 6", value: "30"),
      ItemModel(name: "7 and 14", value: "14"),
    ];
    items2 = [
      ItemModel(name: "24", value: "24"),
      ItemModel(name: "18", value: "18"),
      ItemModel(name: "20", value: "20"),
      ItemModel(name: "30", value: "30"),
      ItemModel(name: "14", value: "14"),
    ];

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
        speak("Correct! Well done!");
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
        speak("Oops! Try again!");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('LCM Matching Game'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameListPage()),
            );
          // Log game completion with final score
           AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/MathNumQuest/LCM_bg.jpg"),
                fit: BoxFit.cover,
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
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Drag the LCM to its matching pair!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Score: $score",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Top Items (targets)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: items.map((item) {
                    return DragTarget<ItemModel>(
                      onAccept: (receivedItem) =>
                          handleMatch(item, receivedItem),
                      builder: (context, accepted, rejected) {
                        return Container(
                          height: 140,
                          width: 140,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 40),

                // Bottom Items (draggables)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: items2.map((item) {
                    return Draggable<ItemModel>(
                      data: item,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        height: 140,
                        width: 140,
                        color: Colors.grey,
                      ),
                      child: Container(
                        height: 140,
                        width: 140,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          item.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: resetGame,
                      child: Text("Reset", style: TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: newGame,
                      child: Text("New Game", style: TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                if (gameOver)
                  Text(
                    "🎉 Game Over! 🎉",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 36),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemModel {
  final String name;
  final String value;

  ItemModel({required this.name, required this.value});
}