import 'package:flutter/material.dart';
import '../analytics_engine.dart'; // Import analytics engine

class WordProblemsGame extends StatefulWidget {
  @override
  _WordProblemsGameState createState() => _WordProblemsGameState();
}

class _WordProblemsGameState extends State<WordProblemsGame> {
  final String gameType = 'triangle_tower'; // Define game type
  int totalScore = 0; // Track total score for analytics
  
  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'If John has 5 apples and he gives 2 to Mary, how many apples does John have left?',
      'answers': ['1 apple', '2 apples', '3 apples', '4 apples'],
      'correctAnswerIndex': 2,
      'explanation':
          'John starts with 5 apples and gives 2 away, so he has 5 - 2 = 3 apples left.',
    },
    {
      'question':
          'Sara has 8 candies and she eats 3 of them. How many candies does Sara have left?',
      'answers': ['2 candies', '3 candies', '4 candies', '5 candies'],
      'correctAnswerIndex': 3,
      'explanation':
          'Sara starts with 8 candies and eats 3, so she has 8 - 3 = 5 candies left.',
    },
    {
      'question': 'What is the smallest prime number?',
      'answers': ['1', '2', '3', '4'],
      'correctAnswerIndex': 1,
      'explanation':
          'The smallest prime number is 2 because it is only divisible by 1 and itself.',
    },
    {
      'question': 'How many factors does the number 12 have?',
      'answers': ['2', '3', '4', '6'],
      'correctAnswerIndex': 3,
      'explanation': 'The number 12 has 6 factors: 1, 2, 3, 4, 6, and 12.',
    },
    {
      'question': 'What is the sum of the first 5 prime numbers?',
      'answers': ['12', '15', '18', '28'],
      'correctAnswerIndex': 3,
      'explanation':
          'The first 5 prime numbers are 2, 3, 5, 7, and 11. Their sum is 2 + 3 + 5 + 7 + 11 = 28.',
    },
  ];

  late Map<String, dynamic> currentQuestion;
  late int? selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    generateQuestion();
    
    // Log game start when game initializes
    AnalyticsEngine.logGameStart(gameType);
  }

  void generateQuestion() {
    int randomIndex = questions.length > 0
        ? (DateTime.now().millisecondsSinceEpoch % questions.length)
        : 0;
    setState(() {
      currentQuestion = questions[randomIndex];
      selectedAnswerIndex = null;
    });
  }

  void _checkAnswer() {
    if (selectedAnswerIndex == currentQuestion['correctAnswerIndex']) {
      totalScore += 10; // Add to total score for analytics
    }
  }

  // Method to end game and log completion (can be called when user decides to finish)
  void endGame() {
    AnalyticsEngine.logGameComplete(gameType, totalScore);
  }

  void _newGame() {
    setState(() {
      totalScore = 0; // Reset total score
      generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Problems Game', style: TextStyle(fontSize: 20)),backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Log game completion with final score
            AnalyticsEngine.logGameCompleteInMiddle();
          },
        ),
      ),
     // appBar: AppBar(
        //title:
          //  Text('Word Problems Game', style: TextStyle(color: Colors.white)),
        //backgroundColor: Colors.blue,
      //),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/MathNumQuest/word_problem.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Solve Some Fun Word Problems!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: generateQuestion,
                    child: Text('Generate Word Problem',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _newGame,
                    child: Text('New Game',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(currentQuestion['question'],
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      ...List.generate(currentQuestion['answers'].length,
                          (index) {
                        return RadioListTile(
                          title: Text(currentQuestion['answers'][index]),
                          value: index,
                          groupValue: selectedAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              selectedAnswerIndex = value;
                            });
                            _checkAnswer(); // Check answer for scoring
                          },
                        );
                      }),
                      if (selectedAnswerIndex != null) ...[
                        SizedBox(height: 20),
                        Text(
                          selectedAnswerIndex ==
                                  currentQuestion['correctAnswerIndex']
                              ? 'Correct! Explanation: ${currentQuestion['explanation']}'
                              : 'Incorrect. Try again!',
                          style: TextStyle(fontSize: 18, color:  Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}