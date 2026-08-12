import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_switcher.dart';
import 'language_provider.dart';
import 'instructions_widget.dart';
import 'score_manager.dart';
import 'analytics_engine.dart';
import 'total_xp_provider.dart';
import 'total_xp_display.dart';
import 'session_score_provider.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';

class EquationDragDrop extends StatefulWidget {
  const EquationDragDrop({super.key});

  @override
  State<EquationDragDrop> createState() => _EquationDragDropState();
}

class DraggableItem extends StatelessWidget {
  final String label;
  final String data;
  @override
  final Key key;

  const DraggableItem({
    required this.label,
    required this.data,
    required this.key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: data,
      feedback: Material(
        elevation: 4.0,
        child: Chip(
          label: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.blue,
        ),
      ),
      childWhenDragging: Chip(
        label: Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 18)),
      ),
      child: Chip(label: Text(label, style: const TextStyle(fontSize: 18))),
    );
  }
}

class DropTarget extends StatefulWidget {
  final List<String> acceptedLabels;
  final bool showResults;
  final List<String> expectedData;
  final ValueChanged<List<String>> onAcceptedLabelsChanged;
  final ValueChanged<String> onItemRemoved;
  final VoidCallback onCorrectAnswer;
  final String label;
  final bool isSpanish;

  const DropTarget({
    super.key,
    required this.acceptedLabels,
    required this.showResults,
    required this.expectedData,
    required this.onAcceptedLabelsChanged,
    required this.onItemRemoved,
    required this.onCorrectAnswer,
    required this.label,
    required this.isSpanish,
  });

  @override
  _DropTargetState createState() => _DropTargetState();
}

class _DropTargetState extends State<DropTarget> {
  bool hasIncorrectItem = false;
  bool showFeedback = false;

  void _resetState() {
    setState(() {
      hasIncorrectItem = false;
      showFeedback = false;
      widget.acceptedLabels.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color targetColor = Colors.grey[300]!;
    if (widget.showResults) {
      if (widget.acceptedLabels.isEmpty) {
        targetColor = Colors.red;
        hasIncorrectItem = true; // Reset the flag if no items are dropped
        showFeedback = true;
      } else if (widget.acceptedLabels
              .every((label) => widget.expectedData.contains(label)) &&
          widget.expectedData.length == widget.acceptedLabels.length) {
        targetColor = Colors.green;
        hasIncorrectItem = false; // Reset the flag if all items are correct
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCorrectAnswer(); // Call the callback when correct
        });
      } else {
        targetColor = Colors.red;
        hasIncorrectItem =
            true; // Set the flag if any incorrect item is dropped
        showFeedback = true; // Show feedback message
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (details) => !widget
              .showResults, // Disable drag-and-drop when results are shown
          onAcceptWithDetails: (details) {
            final String receivedValue = details.data;
            setState(() {
              widget.acceptedLabels
                  .add(receivedValue); // Add the received item to the list
              widget.onAcceptedLabelsChanged(
                  widget.acceptedLabels); // Notify parent of changes
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                color: hasIncorrectItem
                    ? Colors.red
                    : targetColor, // Use red color if any incorrect item is dropped
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label, // Display the drop target label
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.acceptedLabels.isEmpty) ...[
                      Text(
                        widget.isSpanish
                            ? 'Suelta ${widget.label}(s) aquí'
                            : 'Drop ${widget.label}(s) here',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            children: widget.acceptedLabels
                .map((label) => Draggable<String>(
                      data: label,
                      feedback: Material(
                        elevation: 4.0,
                        child: Chip(
                          label: Text(label,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      childWhenDragging: Chip(
                        label: Text(label,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18)),
                      ),
                      onDragCompleted: () {
                        setState(() {
                          widget.acceptedLabels.remove(label);
                          widget.onItemRemoved(label);
                        });
                      },
                      ignoringFeedbackSemantics: widget.showResults,
                      child: Chip(
                        label:
                            Text(label, style: const TextStyle(fontSize: 18)),
                      ), // Disable drag-and-drop when results are shown
                    ))
                .toList(),
          ),
        ),
        if (showFeedback) ...[
          Text(
            'The answer is incorrect. Please try again.',
            style: TextStyle(color: Colors.red),
          )
        ],
      ],
    );
  }
}

class _EquationDragDropState extends State<EquationDragDrop> {
  bool _showResults = false;
  int _currentQuestionIndex = 0;
  int _questionsAnswered = 0; // Counter for the number of questions answered
  bool _gameCompleted = false; // Flag to check if the game is complete
  final ScoreManager _scoreManager = ScoreManager();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final ConfettiController _endGameConfettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  bool _scoreUpdated = false; // Flag to ensure score increments only once
  bool retryVisible =
      false; // Flag to control the visibility of the retry button

  final List<Map<String, dynamic>> _questions = [
    // Your questions here

    {
      'equation': '2x + 3 = 5',
      'draggables': ['2', 'x', '+', '3', '=', '5'],
      'targets': {
        'Coefficient': ['2'],
        'Variable': ['x'],
        'Operator': ['+', '='],
        'Constant': ['3', '5']
      }
    },
    {
      'equation': '3y - 7 = 11',
      'draggables': ['3', 'y', '-', '7', '=', '11'],
      'targets': {
        'Coefficient': ['3'],
        'Variable': ['y'],
        'Operator': ['-', '='],
        'Constant': ['7', '11']
      }
    },
    {
      'equation': '4a + 6 = 10',
      'draggables': ['4', 'a', '+', '6', '=', '10'],
      'targets': {
        'Coefficient': ['4'],
        'Variable': ['a'],
        'Operator': ['+', '='],
        'Constant': ['6', '10']
      }
    },
    {
      'equation': '5b - 8 = 2',
      'draggables': ['5', 'b', '-', '8', '=', '2'],
      'targets': {
        'Coefficient': ['5'],
        'Variable': ['b'],
        'Operator': ['-', '='],
        'Constant': ['8', '2']
      }
    },
    {
      'equation': '6c + 9 = 15',
      'draggables': ['6', 'c', '+', '9', '=', '15'],
      'targets': {
        'Coefficient': ['6'],
        'Variable': ['c'],
        'Operator': ['+', '='],
        'Constant': ['9', '15']
      }
    },
    {
      'equation': '7d - 4 = 3',
      'draggables': ['7', 'd', '-', '4', '=', '3'],
      'targets': {
        'Coefficient': ['7'],
        'Variable': ['d'],
        'Operator': ['-', '='],
        'Constant': ['4', '3']
      }
    },
    {
      'equation': '8e + 12 = 20',
      'draggables': ['8', 'e', '+', '12', '=', '20'],
      'targets': {
        'Coefficient': ['8'],
        'Variable': ['e'],
        'Operator': ['+', '='],
        'Constant': ['12', '20']
      }
    },
    {
      'equation': '9f - 5 = 4',
      'draggables': ['9', 'f', '-', '5', '=', '4'],
      'targets': {
        'Coefficient': ['9'],
        'Variable': ['f'],
        'Operator': ['-', '='],
        'Constant': ['5', '4']
      }
    },
    {
      'equation': '10g + 14 = 24',
      'draggables': ['10', 'g', '+', '14', '=', '24'],
      'targets': {
        'Coefficient': ['10'],
        'Variable': ['g'],
        'Operator': ['+', '='],
        'Constant': ['14', '24']
      }
    },
    {
      'equation': '11h - 9 = 2',
      'draggables': ['11', 'h', '-', '9', '=', '2'],
      'targets': {
        'Coefficient': ['11'],
        'Variable': ['h'],
        'Operator': ['-', '='],
        'Constant': ['9', '2']
      }
    }
  ];

  final Map<String, Map<String, String>> translations = {
    'en': {
      'coefficient': 'Coefficient',
      'variable': 'Variable',
      'operator': 'Operator',
      'constant': 'Constant',
      'check_answers': 'Check Answers',
      'next_question': 'Next Question',
      'game_over': 'Game Over',
      'congratulations': 'Congratulations! Your final score is ',
      'play_again': 'Play Again',
      'retry': 'Retry',
      'instructions':
          'Welcome to Parts of Equations!\n\nLearn and play with equations.\n\nDrag the part of the equation to the correct answer. Once you finish dragging all the parts into the correct boxes, click "Check Answers" button.\n',
    },
    'es': {
      'coefficient': 'Coeficiente',
      'variable': 'Variable',
      'operator': 'Operadora',
      'constant': 'Constante',
      'check_answers': 'Verificar respuestas',
      'next_question': 'Siguiente pregunta',
      'game_over': 'Fin del juego',
      'congratulations': '¡Felicidades! Tu puntaje final es ',
      'play_again': 'Jugar de nuevo',
      'retry': 'Reintentar',
      'instructions':
          '¡Bienvenido a las Partes de Ecuaciones!\n\nAprende y juega con ecuaciones.\n\nArrastra la parte de la ecuación a la respuesta correcta. Una vez que termines de arrastrar todas las partes a las casillas correctas, haz clic en el botón "Verificar respuestas".\n',
    }
  };

  bool _isQuestionAnsweredCorrectly = false;

  late List<Map<String, dynamic>> _shuffledQuestions;
  List<List<String>> _acceptedLabels = List.generate(4, (index) => []);
  final List<Color> _targetBackgroundColors =
      List.generate(4, (index) => Colors.transparent);
  final List<String> _feedbackTexts = List.generate(4, (index) => '');

  // Define a list of GlobalKeys for each DropTarget
  final List<GlobalKey<_DropTargetState>> _dropTargetKeys =
      List.generate(4, (index) => GlobalKey<_DropTargetState>());

  late List<String> _draggables;

  @override
  void initState() {
    super.initState();
    // Provider notifications cannot be dispatched while the route is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<SessionScoreProvider>(context, listen: false)
          .resetGame1Score();
    });
    _shuffledQuestions = List.from(_questions);
    _shuffleQuestions();
    _initializeDraggables();
  }

  void _shuffleQuestions() {
    _shuffledQuestions.shuffle();
  }

  void _initializeDraggables() {
    var currentQuestion = _shuffledQuestions[_currentQuestionIndex];
    var draggables = currentQuestion['draggables'] as List<String>;
    _draggables = List.from(draggables);
  }

  void _checkAnswers() {
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    if (_scoreUpdated) return; // Prevent score from updating more than once
    bool allCorrect = true;
    for (int i = 0; i < _acceptedLabels.length; i++) {
      var targetLabels = _shuffledQuestions[_currentQuestionIndex]['targets']
          .values
          .elementAt(i);
      var acceptedLabels = _acceptedLabels[i];

      // Check if all target labels are in accepted labels and no extra labels are present
      if (!(acceptedLabels.every(targetLabels.contains) &&
          targetLabels.length == acceptedLabels.length)) {
        allCorrect = false;
        _targetBackgroundColors[i] =
            Colors.red; // Set background color to red for incorrect targets
        _feedbackTexts[i] =
            'Incorrect'; // Set feedback text for incorrect targets
      } else {
        _targetBackgroundColors[i] =
            Colors.green; // Set background color to green for correct targets
        _feedbackTexts[i] = 'Correct'; // Set feedback text for correct targets
      }
    }

    if (allCorrect) {
      _showCorrectAnswerFeedback(context);
      _scoreManager.incrementScore(
          10); // Increment the score by 10 if all answers are correct

      // Update session's best score for this game
      final sessionScoreProvider =
          Provider.of<SessionScoreProvider>(context, listen: false);
      sessionScoreProvider.updateGame1Score(_scoreManager.score);
      final combinedSessionScore = sessionScoreProvider.game1BestScore +
          sessionScoreProvider.game2BestScore;
      print('Combined session score - $combinedSessionScore');
      Provider.of<TotalXpProvider>(context, listen: false)
          .updateBestScoreIfNeeded(
              userPin, combinedSessionScore); // Update total XP

      _scoreUpdated = true; // Set flag to true to prevent further score updates
      _confettiController.play(); // Play confetti animation

      // Stop confetti animation after a few seconds
      Timer(const Duration(seconds: 2), () {
        _confettiController.stop();
      });
    } else {
      retryVisible =
          true; // Show the retry button if the answer is wrong/partially wrong
    }

    setState(() {
      _showResults = true;
    });
  }

  void _retry() {
    setState(() {
      for (int i = 0; i < _acceptedLabels.length; i++) {
        _acceptedLabels[i] = [];
        _targetBackgroundColors[i] = Colors.transparent; // or default color
        _feedbackTexts[i] = ''; // Clear feedback text
      }
      for (int i = 0; i < _acceptedLabels.length; i++) {
        _dropTargetKeys[i].currentState?._resetState();
      }
      _showResults = false; // Clear feedback and colors for all targets
      retryVisible = false; // Hide the retry button

      // Reset the draggable items to their original state
      _initializeDraggables();
    });
  }

  void _nextQuestion() {
    setState(() {
      for (int i = 0; i < _acceptedLabels.length; i++) {
        // Clear the values in all drop targets
        _acceptedLabels[i] = [];
        // Reset the background color and feedback text for all targets
        _targetBackgroundColors[i] = Colors.transparent; // or default color
        _feedbackTexts[i] = ''; // Clear feedback text
        // Reset the state of each drop target
        _dropTargetKeys[i].currentState?._resetState();
      }
      _isQuestionAnsweredCorrectly = false;
      _showResults = false; // Clear feedback and colors for all targets
      retryVisible = false; // Hide the retry button
      _currentQuestionIndex =
          (_currentQuestionIndex + 1) % _shuffledQuestions.length;
      _resetDropTargets();
      _scoreUpdated = false; // Reset flag for the new question
      _questionsAnswered++;

      if (_questionsAnswered >= 10) {
        _gameCompleted = true; // Set flag to true if 10 questions are answered
        _endGameConfettiController
            .play(); // Play end-of-game confetti animation
      }

      // Initialize draggables for the next question
      _initializeDraggables();
    });
  }

  void _showCorrectAnswerFeedback(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Correct! Well done'),
      // backgroundColor: Colors.green,
      duration: Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _isQuestionAnsweredCorrectly = true;
  }

  void _resetDropTargets() {
    setState(() {
      _acceptedLabels = List.generate(4, (index) => []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = Provider.of<LanguageProvider>(context).isSpanish;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;

    if (_gameCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isSpanish
              ? translations['es']!['game_over']!
              : translations['en']!['game_over']!),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Congratulations! Your final score is ${_scoreManager.score}.',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Restart the game or navigate to another screen
                  setState(() {
                    _questionsAnswered = 0;
                    _currentQuestionIndex = 0;
                    _gameCompleted = false;
                    _scoreManager.resetScore();
                    _shuffleQuestions();
                    _resetDropTargets();
                  });
                },
                child: Text(isSpanish
                    ? translations['es']!['play_again']!
                    : translations['en']!['play_again']!),
              ),
              const SizedBox(height: 20),
              ConfettiWidget(
                confettiController: _endGameConfettiController,
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
                child: Container(), // Placeholder widget
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'equations_logout',
          onPressed: () => logout(context),
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.logout_rounded,
            color: Color(0xFF6C63FF),
            size: 26,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    var currentQuestion = _shuffledQuestions[_currentQuestionIndex];
    var equation = currentQuestion['equation'];
    var targets = currentQuestion['targets'] as Map<String, List<String>>;
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts of Equations'),
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
          InstructionsWidget(
              instructions: isSpanish
                  ? translations['es']!['instructions']!
                  : translations['en']!['instructions']!),
          Text(
            'PIN: $userPin',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Mathequations/Background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(equation,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 20,
                  runSpacing: 20,
                  children: _draggables
                      .map((label) => DraggableItem(
                            key: Key(label),
                            label: label,
                            data: label,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment
                      .center, // Align children in the center horizontally
                  spacing: 20.0, // Horizontal spacing between children
                  runSpacing: 20.0, // Vertical spacing between rows
                  children: [
                    DropTarget(
                      key: _dropTargetKeys[0],
                      label: isSpanish
                          ? translations['es']!['coefficient']!
                          : translations['en']!['coefficient']!,
                      expectedData: targets['Coefficient']!,
                      showResults: _showResults,
                      acceptedLabels: _acceptedLabels[0],
                      onAcceptedLabelsChanged: (labels) {
                        setState(() {
                          _acceptedLabels[0] = labels;
                          _draggables
                              .removeWhere((item) => labels.contains(item));
                        });
                      },
                      onItemRemoved: (label) {
                        setState(() {
                          if (!_acceptedLabels
                              .any((list) => list.contains(label))) {
                            _draggables.add(label);
                          }
                        });
                      },
                      onCorrectAnswer: _checkAnswers,
                      isSpanish: isSpanish,
                    ),
                    DropTarget(
                      key: _dropTargetKeys[1],
                      label: isSpanish
                          ? translations['es']!['variable']!
                          : translations['en']!['variable']!,
                      expectedData: targets['Variable']!,
                      showResults: _showResults,
                      acceptedLabels: _acceptedLabels[1],
                      onAcceptedLabelsChanged: (labels) {
                        setState(() {
                          _acceptedLabels[1] = labels;
                          _draggables
                              .removeWhere((item) => labels.contains(item));
                        });
                      },
                      onItemRemoved: (label) {
                        setState(() {
                          if (!_acceptedLabels
                              .any((list) => list.contains(label))) {
                            _draggables.add(label);
                          }
                        });
                      },
                      onCorrectAnswer: _checkAnswers,
                      isSpanish: isSpanish,
                    ),
                    DropTarget(
                      key: _dropTargetKeys[2],
                      label: isSpanish
                          ? translations['es']!['operator']!
                          : translations['en']!['operator']!,
                      expectedData: targets['Operator']!,
                      showResults: _showResults,
                      acceptedLabels: _acceptedLabels[2],
                      onAcceptedLabelsChanged: (labels) {
                        setState(() {
                          _acceptedLabels[2] = labels;
                          _draggables
                              .removeWhere((item) => labels.contains(item));
                        });
                      },
                      onItemRemoved: (label) {
                        setState(() {
                          if (!_acceptedLabels
                              .any((list) => list.contains(label))) {
                            _draggables.add(label);
                          }
                        });
                      },
                      onCorrectAnswer: _checkAnswers,
                      isSpanish: isSpanish,
                    ),
                    DropTarget(
                      key: _dropTargetKeys[3],
                      label: isSpanish
                          ? translations['es']!['constant']!
                          : translations['en']!['constant']!,
                      expectedData: targets['Constant']!,
                      showResults: _showResults,
                      acceptedLabels: _acceptedLabels[3],
                      onAcceptedLabelsChanged: (labels) {
                        setState(() {
                          _acceptedLabels[3] = labels;
                          _draggables
                              .removeWhere((item) => labels.contains(item));
                        });
                      },
                      onItemRemoved: (label) {
                        setState(() {
                          if (!_acceptedLabels
                              .any((list) => list.contains(label))) {
                            _draggables.add(label);
                          }
                        });
                      },
                      onCorrectAnswer: _checkAnswers,
                      isSpanish: isSpanish,
                    ),
                  ],
                ),
                if (retryVisible) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Set the background color to blue
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh,
                            color: Colors.white), // Add the refresh icon
                        SizedBox(
                            width:
                                8), // Add some space between the icon and the text
                        Text(
                          isSpanish
                              ? translations['es']!['retry']!
                              : translations['en']!['retry']!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Set the background color to green
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check,
                            color: Colors
                                .white), // Add the check icon with white color
                        SizedBox(
                            width:
                                8), // Add some space between the icon and the text
                        Text(
                          isSpanish
                              ? translations['es']!['check_answers']!
                              : translations['en']!['check_answers']!,
                          style: TextStyle(
                              color:
                                  Colors.white), // Set the text color to white
                        ),
                      ],
                    ),
                  )
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _isQuestionAnsweredCorrectly ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange, // Set the background color to orange
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward,
                          color: Colors
                              .white), // Add the arrow forward icon with white color
                      SizedBox(
                          width:
                              8), // Add some space between the icon and the text
                      Text(
                        isSpanish
                            ? translations['es']!['next_question']!
                            : translations['en']!['next_question']!,
                        style: TextStyle(
                            color: Colors.white), // Set the text color to white
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.yellow
            ],
            child: Container(), // Placeholder widget
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'equations_logout',
        onPressed: () => logout(context),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.logout_rounded,
          color: Color(0xFF6C63FF),
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
