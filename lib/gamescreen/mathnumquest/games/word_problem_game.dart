import 'package:flutter/material.dart';
import '../analytics_engine.dart'; // Import analytics engine

class WordProblemsGame extends StatefulWidget {
  final bool isEnglish;
  const WordProblemsGame({Key? key, this.isEnglish = true}) : super(key: key);

  @override
  _WordProblemsGameState createState() => _WordProblemsGameState();
}

class _WordProblemsGameState extends State<WordProblemsGame> {
  late bool isEnglish;
  String t(String en, String es) => isEnglish ? en : es;

  final String gameType = 'word_problems'; 
  int totalScore = 0; 

  late Map<String, dynamic> currentQuestion;
  late int? selectedAnswerIndex;

  final List<Map<String, dynamic>> questions = [
    {
      'question_en':
          'If John has 5 apples and he gives 2 to Mary, how many apples does John have left?',
      'question_es':
          'Si John tiene 5 manzanas y le da 2 a Mary, ¿cuántas manzanas le quedan a John?',
      'answers_en': ['1 apple', '2 apples', '3 apples', '4 apples'],
      'answers_es': ['1 manzana', '2 manzanas', '3 manzanas', '4 manzanas'],
      'correctAnswerIndex': 2,
      'explanation_en':
          'John starts with 5 apples and gives away 2, so he has 5 - 2 = 3 apples left.',
      'explanation_es':
          'John comienza con 5 manzanas y regala 2, así que le quedan 5 - 2 = 3 manzanas.',
    },
    {
      'question_en':
          'Sara has 8 candies and she eats 3. How many candies does she have left?',
      'question_es':
          'Sara tiene 8 caramelos y se come 3. ¿Cuántos caramelos le quedan?',
      'answers_en': ['2 candies', '3 candies', '4 candies', '5 candies'],
      'answers_es': ['2 caramelos', '3 caramelos', '4 caramelos', '5 caramelos'],
      'correctAnswerIndex': 3,
      'explanation_en':
          'Sara starts with 8 candies and eats 3, so she has 5 left.',
      'explanation_es':
          'Sara comienza con 8 caramelos y se come 3, así que le quedan 5.',
    },
    {
      'question_en': 'What is the smallest prime number?',
      'question_es': '¿Cuál es el número primo más pequeño?',
      'answers_en': ['1', '2', '3', '4'],
      'answers_es': ['1', '2', '3', '4'],
      'correctAnswerIndex': 1,
      'explanation_en':
          'The smallest prime number is 2 because it is divisible only by 1 and itself.',
      'explanation_es':
          'El número primo más pequeño es 2 porque solo es divisible por 1 y por sí mismo.',
    },
    {
      'question_en': 'How many factors does 12 have?',
      'question_es': '¿Cuántos factores tiene el número 12?',
      'answers_en': ['2', '3', '4', '6'],
      'answers_es': ['2', '3', '4', '6'],
      'correctAnswerIndex': 3,
      'explanation_en':
          '12 has 6 factors: 1, 2, 3, 4, 6, and 12.',
      'explanation_es':
          'El número 12 tiene 6 factores: 1, 2, 3, 4, 6 y 12.',
    },
    {
      'question_en': 'What is the sum of the first 5 prime numbers?',
      'question_es': '¿Cuál es la suma de los primeros 5 números primos?',
      'answers_en': ['12', '15', '18', '28'],
      'answers_es': ['12', '15', '18', '28'],
      'correctAnswerIndex': 3,
      'explanation_en':
          'The first 5 prime numbers are 2, 3, 5, 7, and 11. Their sum is 28.',
      'explanation_es':
          'Los primeros 5 números primos son 2, 3, 5, 7 y 11. Su suma es 28.',
    },
  ];

  @override
  void initState() {
    super.initState();
    isEnglish = widget.isEnglish;
    generateQuestion();
    AnalyticsEngine.logGameStart(gameType);
  }

  void generateQuestion() {
    int randomIndex = DateTime.now().millisecondsSinceEpoch % questions.length;
    setState(() {
      currentQuestion = questions[randomIndex];
      selectedAnswerIndex = null;
    });
  }

  void _checkAnswer() {
    if (selectedAnswerIndex == currentQuestion['correctAnswerIndex']) {
      totalScore += 10;
    }
  }

  void endGame() {
    AnalyticsEngine.logGameComplete(gameType, totalScore);
  }

  void _newGame() {
    setState(() {
      totalScore = 0;
      generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    List answers = isEnglish
        ? currentQuestion['answers_en']
        : currentQuestion['answers_es'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          t('Word Problems Game', 'Juego de Problemas Verbales'),
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
              });
              AnalyticsEngine.logGameTranslateButtonClick();
            },
            label: Text(
              isEnglish ? 'Tap to Translate' : 'Toca para Traducir',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold,fontSize: 18),
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

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/word_problem.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                t('Solve Some Fun Word Problems!',
                   '¡Resuelve algunos problemas divertidos!'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: generateQuestion,
                    child: Text(
                      t('Generate Word Problem', 'Generar Problema'),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _newGame,
                    child: Text(
                      t('New Game', 'Nuevo Juego'),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                      Text(
                        t(currentQuestion['question_en'],
                          currentQuestion['question_es']),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      ...List.generate(answers.length, (index) {
                        return RadioListTile(
                          title: Text(answers[index]),
                          value: index,
                          groupValue: selectedAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              selectedAnswerIndex = value;
                            });
                            _checkAnswer();
                          },
                        );
                      }),

                      if (selectedAnswerIndex != null) ...[
                        SizedBox(height: 20),
                        Text(
                          selectedAnswerIndex ==
                                  currentQuestion['correctAnswerIndex']
                              ? t(
                                  'Correct! Explanation: ${currentQuestion['explanation_en']}',
                                  '¡Correcto! Explicación: ${currentQuestion['explanation_es']}',
                                )
                              : t('Incorrect. Try again!',
                                  'Incorrecto. ¡Inténtalo de nuevo!'),
                          style: TextStyle(fontSize: 18, color: Colors.green),
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