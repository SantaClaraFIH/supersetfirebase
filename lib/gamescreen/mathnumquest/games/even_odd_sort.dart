import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../analytics_engine.dart'; // Import analytics engine

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
  @override
  _EvenOddSortPageState createState() => _EvenOddSortPageState();
}

class _EvenOddSortPageState extends State<EvenOddSortPage> {
  List<int> evenNumbers = [];
  List<int> oddNumbers = [];
  List<int> bottomNumbers = List.generate(6, (index) => Random().nextInt(99) + 1);
  List<int> initialBottomNumbers = [];
  bool? isCorrect;
  int score = 0;
  late FlutterTts flutterTts;
  late ConfettiController confettiController;
  final String gameType = 'even_odd_sort'; // Define game type
  int totalScore = 0; // Track total score for analytics

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    confettiController = ConfettiController(duration: Duration(seconds: 1));
    initialBottomNumbers = List.from(bottomNumbers);
    
    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  @override
  void dispose() {
    confettiController.dispose();
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
      totalScore += 10; // Add to total score for analytics
      speak("Correct! Well done");
      confettiController.play();
    } else {
      speak("Oops! Try again");
    }

    setState(() {});
  }

  void newGame() {
    setState(() {
      evenNumbers.clear();
      oddNumbers.clear();
      bottomNumbers = List.generate(6, (index) => Random().nextInt(99) + 1);
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

  Widget buildDragTarget(String label, Color color, List<int> numbersList) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 200,
          height: 250,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              "$label\n${numbersList.join(', ')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      onAccept: (number) {
        setState(() {
          numbersList.add(number);
          bottomNumbers.remove(number);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Even Odd Sort"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            endGame();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              Text("Drag and drop each number to its correct group",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Score: $score", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDragTarget("EVEN", Colors.green, evenNumbers),
                  buildDragTarget("ODD", Colors.blue, oddNumbers),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: bottomNumbers.map((number) {
                  return Draggable<int>(
                    data: number,
                    child: buildNumberBox(number),
                    feedback: Material(child: buildNumberBox(number, dragging: true)),
                    childWhenDragging: Container(),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: checkNumbers,
                      child: Text("Check", style: TextStyle(fontSize: 20)),
                    ),
                    ElevatedButton(
                      onPressed: resetGame,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: Text("Reset", style: TextStyle(fontSize: 20)),
                    ),
                    ElevatedButton(
                      onPressed: newGame,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text("Next Game", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (isCorrect != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    isCorrect! ? "Correct!" : "Incorrect. Try again!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isCorrect! ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberBox(int number, {bool dragging = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: dragging ? Colors.pink.withOpacity(0.5) : Colors.pink,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        "$number\n(${numberToText(number)})",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}