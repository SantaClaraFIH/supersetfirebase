import 'package:confetti/confetti.dart';
import 'package:supersetfirebase/gamescreen/mathequations/analytics_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'instructions_widget.dart';
import 'score_manager.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'total_xp_display.dart';
import 'total_xp_provider.dart';
import 'language_switcher.dart';
import 'language_provider.dart';
import 'session_score_provider.dart';

class EquationToWordsScreen extends StatefulWidget {
  const EquationToWordsScreen({super.key});

  @override
  State<EquationToWordsScreen> createState() => _EquationToWordsScreenState();
}

class _EquationToWordsScreenState extends State<EquationToWordsScreen> {
  List<DraggableItem> draggableItems = [];

  final Map<String, Map<String, String>> translations = {
    'en': {
      'check_answers': 'Check Answers',
      'next_question': 'Next Question',
      'game_over': 'Game Over',
      'congratulations': 'Congratulations! Your final score is ',
      'play_again': 'Play Again',
      'correct': 'Correct! Well done',
      'incorrect': 'Incorrect. Try again.',
      'drop_items': 'Drop items here',
      'instructions':
          'Welcome to Parts of Equations!\n\nLearn and play with equations.\n\nDrag the part of the equation to the correct answer. Once you finish dragging all the parts into the correct boxes, click "Check Answers" button.\n',
    },
    'es': {
      'check_answers': 'Verificar respuestas',
      'next_question': 'Siguiente pregunta',
      'game_over': 'Fin del juego',
      'congratulations': '¡Felicidades! Tu puntaje final es ',
      'play_again': 'Jugar de nuevo',
      'correct': '¡Correcto! Bien hecho',
      'incorrect': 'Incorrecto. Inténtalo de nuevo.',
      'drop_items': 'Suelta los elementos aquí',
      'instructions':
          '¡Bienvenido a "Ecuaciones a Palabras"!\n\nAprende y juega con las ecuaciones.\n\nArrastra y suelta las palabras dadas en el orden correcto para que coincidan con cómo se lee una ecuación en voz alta.\n',
    }
  };

  final List<Map<String, dynamic>> easyQuestions = [
    {
      'equation': '2x + 4 = 8',
      'words': ['x', 'four', 'times', 'equals', 'two', 'eight', 'plus'],
      'translated': ['x', 'cuatro', 'veces', 'igual', 'dos', 'ocho', 'más'],
      'answer': ['two', 'times', 'x', 'plus', 'four', 'equals', 'eight'],
      'translatedAnswer': [
        'dos',
        'veces',
        'x',
        'más',
        'cuatro',
        'igual',
        'ocho'
      ],
    },
    {
      'equation': '3y - 5 = 10',
      'words': ['y', 'three', 'minus', 'equals', 'five', 'ten'],
      'translated': ['y', 'tres', 'menos', 'igual', 'cinco', 'diez'],
      'answer': ['three', 'y', 'minus', 'five', 'equals', 'ten'],
      'translatedAnswer': ['tres', 'y', 'menos', 'cinco', 'igual', 'diez'],
    },
    {
      'equation': '4a + 7 = 19',
      'words': ['a', 'four', 'plus', 'equals', 'seven', 'nineteen'],
      'translated': ['a', 'cuatro', 'más', 'igual', 'siete', 'diecinueve'],
      'answer': ['four', 'a', 'plus', 'seven', 'equals', 'nineteen'],
      'translatedAnswer': [
        'cuatro',
        'a',
        'más',
        'siete',
        'igual',
        'diecinueve'
      ],
    },
    {
      'equation': '5b - 2 = 13',
      'words': ['b', 'five', 'minus', 'equals', 'two', 'thirteen'],
      'translated': ['b', 'cinco', 'menos', 'igual', 'dos', 'trece'],
      'answer': ['five', 'b', 'minus', 'two', 'equals', 'thirteen'],
      'translatedAnswer': ['cinco', 'b', 'menos', 'dos', 'igual', 'trece'],
    },
    {
      'equation': '6c + 3 = 21',
      'words': ['c', 'six', 'plus', 'equals', 'three', 'twenty-one'],
      'translated': ['c', 'seis', 'más', 'igual', 'tres', 'veintiuno'],
      'answer': ['six', 'c', 'plus', 'three', 'equals', 'twenty-one'],
      'translatedAnswer': ['seis', 'c', 'más', 'tres', 'igual', 'veintiuno'],
    },
  ];

  final List<Map<String, dynamic>> mediumQuestions = [
    {
      'equation': '7d - 4 = 17',
      'words': ['d', 'seven', 'minus', 'equals', 'four', 'seventeen'],
      'translated': ['d', 'siete', 'menos', 'igual', 'cuatro', 'diecisiete'],
      'answer': ['seven', 'd', 'minus', 'four', 'equals', 'seventeen'],
      'translatedAnswer': [
        'siete',
        'd',
        'menos',
        'cuatro',
        'igual',
        'diecisiete'
      ],
    },
    {
      'equation': '8e + 2 = 18',
      'words': ['e', 'eight', 'plus', 'equals', 'two', 'eighteen'],
      'translated': ['e', 'ocho', 'más', 'igual', 'dos', 'dieciocho'],
      'answer': ['eight', 'e', 'plus', 'two', 'equals', 'eighteen'],
      'translatedAnswer': ['ocho', 'e', 'más', 'dos', 'igual', 'dieciocho'],
    },
    {
      'equation': '2x + 3y = 14',
      'words': ['x', 'y', 'two', 'three', 'plus', 'equals', 'fourteen'],
      'translated': ['x', 'y', 'dos', 'tres', 'más', 'igual', 'catorce'],
      'answer': ['two', 'x', 'plus', 'three', 'y', 'equals', 'fourteen'],
      'translatedAnswer': ['dos', 'x', 'más', 'tres', 'y', 'igual', 'catorce'],
    },
    {
      'equation': '4a - 5b = 12',
      'words': ['a', 'b', 'four', 'five', 'minus', 'equals', 'twelve'],
      'translated': ['a', 'b', 'cuatro', 'cinco', 'menos', 'igual', 'doce'],
      'answer': ['four', 'a', 'minus', 'five', 'b', 'equals', 'twelve'],
      'translatedAnswer': [
        'cuatro',
        'a',
        'menos',
        'cinco',
        'b',
        'igual',
        'doce'
      ],
    },
    {
      'equation': '6c + 7d = 29',
      'words': ['c', 'd', 'six', 'seven', 'plus', 'equals', 'twenty-nine'],
      'translated': ['c', 'd', 'seis', 'siete', 'más', 'igual', 'veintinueve'],
      'answer': ['six', 'c', 'plus', 'seven', 'd', 'equals', 'twenty-nine'],
      'translatedAnswer': [
        'seis',
        'c',
        'más',
        'siete',
        'd',
        'igual',
        'veintinueve'
      ],
    },
  ];

  final List<Map<String, dynamic>> hardQuestions = [
    {
      'equation': '3/2x + 1 = 4/3',
      'words': [
        'one',
        'three',
        'two',
        'x',
        'four',
        'over',
        'thirds',
        'plus',
        'equals'
      ],
      'translated': [
        'uno',
        'tres',
        'dos',
        'x',
        'cuatro',
        'sobre',
        'tercios',
        'más',
        'igual'
      ],
      'answer': [
        'three',
        'over',
        'two',
        'x',
        'plus',
        'one',
        'equals',
        'four',
        'thirds'
      ],
      'translatedAnswer': [
        'tres',
        'sobre',
        'dos',
        'x',
        'más',
        'uno',
        'igual',
        'cuatro',
        'tercios'
      ]
    },
    {
      'equation': '1/2x = 5/6',
      'words': ['half', 'equals', 'sixths', 'one', 'x', 'five'],
      'translated': ['medio', 'igual', 'sextos', 'uno', 'x', 'cinco'],
      'answer': ['one', 'half', 'x', 'equals', 'five', 'sixths'],
      'translatedAnswer': ['uno', 'medio', 'x', 'igual', 'cinco', 'sextos']
    },
    {
      'equation': 'x/3 + 2/3 = 1',
      'words': ['two', 'one', 'x', 'equals', 'three', 'plus', 'thirds', 'over'],
      'translated': [
        'dos',
        'uno',
        'x',
        'igual',
        'tres',
        'más',
        'tercios',
        'sobre'
      ],
      'answer': [
        'x',
        'over',
        'three',
        'plus',
        'two',
        'thirds',
        'equals',
        'one'
      ],
      'translatedAnswer': [
        'x',
        'sobre',
        'tres',
        'más',
        'dos',
        'tercios',
        'igual',
        'uno'
      ]
    },
    {
      'equation': '2x/5 = 4/5',
      'words': ['x', 'five', 'equals', 'two', 'over', 'four', 'fifths'],
      'translated': [
        'x',
        'cinco',
        'igual',
        'dos',
        'sobre',
        'cuatro',
        'quintos'
      ],
      'answer': ['two', 'x', 'over', 'five', 'equals', 'four', 'fifths'],
      'translatedAnswer': [
        'dos',
        'x',
        'sobre',
        'cinco',
        'igual',
        'cuatro',
        'quintos'
      ]
    },
    {
      'equation': '3x + 1/4 = 5/2',
      'words': [
        'five',
        'plus',
        'equals',
        'halves',
        'x',
        'fourth',
        'one',
        'three'
      ],
      'translated': [
        'cinco',
        'más',
        'igual',
        'medios',
        'x',
        'fourth',
        'uno',
        'tres'
      ],
      'answer': [
        'three',
        'x',
        'plus',
        'one',
        'fourth',
        'equals',
        'five',
        'halves'
      ],
      'translatedAnswer': [
        'tres',
        'x',
        'más',
        'uno',
        'fourth',
        'igual',
        'cinco',
        'medios'
      ]
    },
    {
      'equation': '1/4x - 2/3 = 0',
      'words': [
        'two',
        'x',
        'minus',
        'fourth',
        'zero',
        'one',
        'thirds',
        'equals'
      ],
      'translated': [
        'dos',
        'x',
        'menos',
        'fourth',
        'cero',
        'uno',
        'tercios',
        'igual'
      ],
      'answer': [
        'one',
        'fourth',
        'x',
        'minus',
        'two',
        'thirds',
        'equals',
        'zero'
      ],
      'translatedAnswer': [
        'uno',
        'fourth',
        'x',
        'menos',
        'dos',
        'tercios',
        'igual',
        'cero'
      ]
    },
    {
      'equation': 'x + 2/2 = 3/4',
      'words': ['two', 'three', 'x', 'equals', 'halves', 'plus', 'fourths'],
      'translated': ['dos', 'tres', 'x', 'igual', 'medios', 'más', 'cuartos'],
      'answer': ['x', 'plus', 'two', 'halves', 'equals', 'three', 'fourths'],
      'translatedAnswer': [
        'x',
        'más',
        'dos',
        'medios',
        'igual',
        'tres',
        'cuartos'
      ]
    },
    {
      'equation': '2/3x + 1/2 = 7/6',
      'words': [
        'two',
        'thirds',
        'one',
        'equals',
        'x',
        'sixths',
        'seven',
        'plus',
        'half'
      ],
      'translated': [
        'dos',
        'tercios',
        'uno',
        'igual',
        'x',
        'sextos',
        'siete',
        'más',
        'medio'
      ],
      'answer': [
        'two',
        'thirds',
        'x',
        'plus',
        'one',
        'half',
        'equals',
        'seven',
        'sixths'
      ],
      'translatedAnswer': [
        'dos',
        'tercios',
        'x',
        'más',
        'uno',
        'medio',
        'igual',
        'siete',
        'sextos'
      ]
    },
    {
      'equation': '5x + 4y - 3z = 10',
      'words': [
        'x',
        'y',
        'z',
        'five',
        'four',
        'three',
        'plus',
        'minus',
        'equals',
        'ten'
      ],
      'translated': [
        'x',
        'y',
        'z',
        'cinco',
        'cuatro',
        'tres',
        'más',
        'menos',
        'igual',
        'diez'
      ],
      'answer': [
        'five',
        'x',
        'plus',
        'four',
        'y',
        'minus',
        'three',
        'z',
        'equals',
        'ten'
      ],
      'translatedAnswer': [
        'cinco',
        'x',
        'más',
        'cuatro',
        'y',
        'menos',
        'tres',
        'z',
        'igual',
        'diez'
      ],
    },
    {
      'equation': '7p + 2q - r = 15',
      'words': [
        'p',
        'q',
        'r',
        'seven',
        'two',
        'one',
        'plus',
        'minus',
        'equals',
        'fifteen'
      ],
      'translated': [
        'p',
        'q',
        'r',
        'siete',
        'dos',
        'uno',
        'más',
        'menos',
        'igual',
        'quince'
      ],
      'answer': [
        'seven',
        'p',
        'plus',
        'two',
        'q',
        'minus',
        'one',
        'r',
        'equals',
        'fifteen'
      ],
      'translatedAnswer': [
        'siete',
        'p',
        'más',
        'dos',
        'q',
        'menos',
        'uno',
        'r',
        'igual',
        'quince'
      ],
    }
  ];

  bool _isQuestionAnsweredCorrectly = false;
  int currentQuestionIndex = 0;
  List<Map<String, String>> userAnswer = [];
  final ScoreManager _scoreManager = ScoreManager();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  int currentLevel = 1;
  int totalQuestionsAnswered = 0;
  List<Map<String, dynamic>> currentLevelQuestions = [];

  final FlutterTts _flutterTts = FlutterTts();
  Future<void> _speak(String text) async {
    // Initialize TTS
    final isSpanish =
        Provider.of<LanguageProvider>(context, listen: false).isSpanish;
    String language = isSpanish ? "es-ES" : "en-US";
    await _flutterTts.setLanguage(language);
    await _flutterTts.setPitch(1.0);
    var result = await _flutterTts.speak(text);
    print("TTS result: $result");
  }

  @override
  void initState() {
    super.initState();
    // Provider notifications cannot be dispatched while the route is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<SessionScoreProvider>(context, listen: false)
          .resetGame2Score();
    });
    _loadLevelQuestions();
    _loadRandomQuestion();
  }

  void _loadLevelQuestions() {
    if (currentLevel == 1) {
      currentLevelQuestions = List.from(easyQuestions)..shuffle();
    } else if (currentLevel == 2) {
      currentLevelQuestions = List.from(mediumQuestions)..shuffle();
    } else if (currentLevel == 3) {
      currentLevelQuestions = List.from(hardQuestions)..shuffle();
    }
  }

  void _loadRandomQuestion() {
    currentQuestionIndex =
        totalQuestionsAnswered % currentLevelQuestions.length;
    userAnswer = List<Map<String, String>>.filled(
      currentLevelQuestions[currentQuestionIndex]['answer'].length,
      {'english': '', 'spanish': ''},
      growable: false,
    );
  }

  void _checkAnswer() async{
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    final isSpanish =
        Provider.of<LanguageProvider>(context, listen: false).isSpanish;
    final answer = currentLevelQuestions[currentQuestionIndex]
        [isSpanish ? 'translatedAnswer' : 'answer'] as List<String>;

    // Join all the 'english' values from userAnswer
    final userJoinedEnglishAnswer = userAnswer
        .map((map) => map['english'] ?? '') // Extract 'english' values
        .join(' '); // Join them into a single string
    // Join all the 'english' values from userAnswer

    final userJoinedSpanishAnswer = userAnswer
        .map((map) => map['spanish'] ?? '') // Extract 'english' values
        .join(' '); // Join them into a single string

    final result =
        isSpanish ? userJoinedSpanishAnswer : userJoinedEnglishAnswer;


    if (result == answer.join(' ')) {  
      await _speak(result);
      await _speak(isSpanish
        ? translations['es']!['correct']!
        : translations['en']!['correct']!);
      setState(() {
        _scoreManager.incrementScore(10); // Increment score by 10

        // Update session's best score for this game
        final sessionScoreProvider =
            Provider.of<SessionScoreProvider>(context, listen: false);
        sessionScoreProvider.updateGame2Score(_scoreManager.score);
        final combinedSessionScore = sessionScoreProvider.game1BestScore +
            sessionScoreProvider.game2BestScore;
        print('Combined session score - $combinedSessionScore');
        Provider.of<TotalXpProvider>(context, listen: false)
            .updateBestScoreIfNeeded(userPin, combinedSessionScore);

        _confettiController.play(); // Play confetti on correct answer
        totalQuestionsAnswered++;
        _isQuestionAnsweredCorrectly = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isSpanish
              ? translations['es']!['correct']!
              : translations['en']!['correct']!,
        ),
        backgroundColor: Colors.green,
      ));
    } else {
      await _speak(isSpanish
        ? translations['es']!['incorrect']!
        : translations['en']!['incorrect']!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish
                ? translations['es']!['incorrect']!
                : translations['en']!['incorrect']!,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNextQuestionButtonClicked() {
    if (totalQuestionsAnswered % currentLevelQuestions.length == 0) {
      _showLevelCompleteDialog(); // Show level complete dialog
    } else {
      _loadRandomQuestion(); // Load the next random question
    }
    setState(() {
      _isQuestionAnsweredCorrectly =
          false; // Reset the flag for the next question
    });
  }

  void _showLevelCompleteDialog() {
    if (currentLevel >= 3) {
      _showFinalScoreDialog(); // End the game after Level 3
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Level Complete!'),
          content: Text(
              'Congratulations! You\'ve completed Level $currentLevel.\nYour score is: ${_scoreManager.score}.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Next Level'),
              onPressed: () {
                setState(() {
                  currentLevel++;
                  if (currentLevel > 3) {
                    _showFinalScoreDialog(); // End the game after Level 3
                  } else {
                    totalQuestionsAnswered = 0;
                    _loadLevelQuestions(); // Load questions for the new level
                    _loadRandomQuestion(); // Load the first question of the new level
                  }
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Complete!'),
          content: Text(
              'You\'ve completed all levels! Your final score is: ${_scoreManager.score}.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart Game'),
              onPressed: () {
                setState(() {
                  currentLevel = 1;
                  totalQuestionsAnswered = 0;
                  _scoreManager.resetScore();
                  _loadLevelQuestions();
                  _loadRandomQuestion();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = currentLevelQuestions[currentQuestionIndex];
    final equation = currentQuestion['equation'] as String;
    final isSpanish = Provider.of<LanguageProvider>(context).isSpanish;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;
    final words = isSpanish
        ? currentQuestion['translated']
        : currentQuestion['words'] as List<String>;
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Equations to Words - Level $currentLevel'),
        actions: [
          LanguageSwitcher(
            isSpanish: isSpanish,
            onLanguageChanged: (bool newIsSpanish) {
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLanguage(newIsSpanish);
              AnalyticsEngine.logTranslateButtonClickETW(
                  newIsSpanish ? 'Changed to Spanish' : 'Changed to English');
            },
          ),
          const SizedBox(width: 16),
          Text(
            'PIN: $userPin',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          InstructionsWidget(
            instructions: isSpanish
                ? translations['es']!['instructions']!
                : translations['en']!['instructions']!,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Mathequations/Background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          equation,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Drop Targets
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: List.generate(userAnswer.length, (index) {
                            return DropTarget(
                              index: index,
                              label: isSpanish
                                  ? (userAnswer[index]['spanish']?.isNotEmpty ??
                                          false)
                                      ? userAnswer[index]['spanish']!
                                      : translations['es']!['drop_items']!
                                  : (userAnswer[index]['english']?.isNotEmpty ??
                                          false)
                                      ? userAnswer[index]['english']!
                                      : translations['en']!['drop_items']!,
                              onAccept: (receivedItem) {
                                setState(() {
                                  int wordIndex = words.indexOf(receivedItem);
                                  userAnswer[index] = {
                                    'english': currentQuestion['words']
                                        [wordIndex],
                                    'spanish': currentQuestion['translated']
                                        [wordIndex],
                                  };
                                });
                              },
                            );
                          }),
                        ),

                        const SizedBox(height: 40),

                        // Draggable Items (Styled like POE)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: words.map<Widget>((word) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DraggableItem(
                                label: word,
                                data: word,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 40),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _checkAnswer,
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              label: Text(
                                isSpanish
                                    ? translations['es']!['check_answers']!
                                    : translations['en']!['check_answers']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: _isQuestionAnsweredCorrectly
                                  ? _onNextQuestionButtonClicked
                                  : null,
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                              label: Text(
                                isSpanish
                                    ? translations['es']!['next_question']!
                                    : translations['en']!['next_question']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
          Positioned(
            top: kToolbarHeight + 2, // Position below the app bar
            right: 4, // Align to the right
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScoreDisplay(score: _scoreManager.score),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TotalXpDisplay(totalXp: totalXp),
                ),
              ],
            ),
          ),

          // Confetti Effect
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.yellow
              ],
              numberOfParticles: 10,
              emissionFrequency: 0.1,
              gravity: 0.1,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'equations_logout',
        onPressed: () => logout(context),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.logout_rounded,
          color: Colors.black,
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DraggableItem extends StatelessWidget {
  final String label;
  final String data;

  const DraggableItem({
    super.key,
    required this.label,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        elevation: 4.0, // No background for feedback chip
        child: Chip(
          label: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.blue, // Blue background while dragging
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildDraggableContent(context),
      ),
      child: _buildDraggableContent(context),
        onDragStarted: () {
        final parentState = context.findAncestorStateOfType<_EquationToWordsScreenState>();
        parentState?._speak(label);
      },
    );
  }

  Widget _buildDraggableContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              final parentState = context
                  .findAncestorStateOfType<_EquationToWordsScreenState>();
              parentState?._speak(label);
              AnalyticsEngine.logAudioButtonClick(
                  Provider.of<LanguageProvider>(context, listen: false)
                      .isSpanish,
                  'Equations To Words');
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up,
                size: 16, // Smaller size for a subtle look
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropTarget extends StatelessWidget {
  final int index;
  final String label;
  final Function(String) onAccept;

  const DropTarget(
      {super.key,
      required this.index,
      required this.label,
      required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      // always accept
      onWillAcceptWithDetails: (_) => true,

      // extract the String from details.data
      onAcceptWithDetails: (details) {
        onAccept(details.data);
      },

      builder: (context, candidateData, rejectedData) {
        bool isPlaceholder =
            label == 'Drop items here' || label == 'Suelta los elementos aquí';
        return Container(
          width: 125,
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isPlaceholder ? 16 : 20,
                fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
                color: isPlaceholder ? Colors.grey : Colors.blue,
              ),
            ),
          )),
        );
      },
    );
  }
}

class ScoreDisplay extends StatelessWidget {
  final int score;

  const ScoreDisplay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rocket_launch,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          Text(
            'Current Score: $score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
