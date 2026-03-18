// lib/gamescreen/mathmingle/memory.dart
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'score_topbar.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class GameData1 extends ChangeNotifier {
  int total = 0;
  void setTotal(int value) {
    total += value;
    notifyListeners();
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late AudioPlayer _tickPlayer;
  late AudioPlayer _wordPlayer;
  late AudioPlayer _audioPlayer;
  bool _showCorrectIcon = false;
  int _currentlyFlippedCount = 0;
  late ConfettiController _confettiController;
  int _previousIndex = -1;
  bool _flip = false;
  bool _wait = false;
  List<String> _data = [];
  List<bool> _cardFlips = [];
  List<GlobalKey<FlipCardState>> _cardStateKeys = [];
  Map<String, String> _translations = {};
  int _matchedPairs = 0;
  int? chapter;
  late Timer _timer;
  int _seconds = 120;

  @override
  void initState() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    // Initialize audio players
    _audioPlayer = AudioPlayer();
    _tickPlayer = AudioPlayer();
    _wordPlayer = AudioPlayer();
    super.initState();
    _initializeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chapter = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
      _translations = getTranslations(chapter!);
      restart();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    _tickPlayer.dispose();
    _wordPlayer.dispose();
    super.dispose();
    _confettiController.dispose();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer.cancel();
          _handleTimeUp();
        }
      });
    });
  }

  void _handleTimeUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Times up! Try again.",
              style: TextStyle(fontSize: 25)),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart Game'),
              onPressed: () {
                Navigator.pop(context);
                restart();
                setState(() {
                  _seconds = 120;
                  _initializeTimer();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void restart() {
    setState(() {
      _data = getSourceArray(chapter!);
      _cardFlips = List<bool>.filled(_data.length, true);
      _cardStateKeys =
          List.generate(_data.length, (_) => GlobalKey<FlipCardState>());
      _matchedPairs = 0;
      _flip = false;
      _wait = false;
      _currentlyFlippedCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    int crossAxisCount = isPortrait ? 4 : 5;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBarWithScore(
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.height > 700 ? 56 : 27,
        height: MediaQuery.of(context).size.height > 700 ? 56 : 27,
        child: FloatingActionButton(
          heroTag: "logoutButton",
          onPressed: () => logout(context),
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.logout_rounded,
            size: MediaQuery.of(context).size.height > 700 ? 28 : 20,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // Prevents UI elements from going behind status bar
          child: SingleChildScrollView(
            // Prevents bottom overflow
            //child: Column(
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    const SizedBox(height: 10),

                    // Title & Timer
                    Text(
                      'R E M E M B E R  &  W I N',
                      style: TextStyle(
                          //fontSize: 50,
                          fontSize: MediaQuery.of(context).size.width > 600
                              ? 50 // Set max font size for larger windows
                              : MediaQuery.of(context).size.width /
                                  14, // Dynamically scale for smaller windows
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0),
                      textAlign: TextAlign.center,
                      strutStyle: StrutStyle(height: 1.0),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double screenWidth = constraints.maxWidth;

                            // Check if the screen width is large enough to maintain the 350px width
                            double imageWidth =
                                screenWidth > 600 ? 350 : screenWidth * 0.50;

                            return Image.asset(
                              "assets/Mathmingle/Memory_game_background.png",
                              width: imageWidth,
                              fit: BoxFit
                                  .cover, // Ensures the image scales correctly
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 70),
                          child: ClockDisplay(seconds: _seconds),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    // Game Grid
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.6, // Limits grid height to prevent overflow
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Step 3: Add this condition to allow flipping only if less than 2 cards are flipped
                                    if (_wait || !_cardFlips[index]) return;
                                    if (_cardStateKeys[index]
                                            .currentState
                                            ?.isFront ==
                                        false) return;
                                    if (_currentlyFlippedCount >= 2) return;

                                    _cardStateKeys[index]
                                        .currentState
                                        ?.toggleCard();
                                    _currentlyFlippedCount++;
                                    checkMatch(index);
                                  },
                                  child: FlipCard(
                                    key: _cardStateKeys[index],
                                    flipOnTouch: false, // turn off auto-flip
                                    direction: FlipDirection.HORIZONTAL,
                                    front: getQuestionMarkCard(),
                                    back: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: _cardFlips[index]
                                                ? Colors.grey[100]
                                                : Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: !_cardFlips[index]
                                                  ? Colors.white
                                                  : Colors
                                                      .transparent, // White border
                                              width:
                                                  4, // Thicker border for more emphasis
                                            ),
                                            boxShadow: !_cardFlips[index]
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(
                                                              0.9), // Almost fully bright white
                                                      blurRadius:
                                                          20, // Higher blur makes glow softer and larger
                                                      spreadRadius:
                                                          5, // Makes the glow spread outward more
                                                      offset: const Offset(0,
                                                          0), // Centered glow
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              _data[index],
                                              style: TextStyle(
                                                fontSize:
                                                    constraints.maxWidth / 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final double scale = width < 600
                          ? 0.5
                          : 1.0; // Scale down on small screens
                      final double emissionFrequency = width < 600
                          ? 0.05 * scale
                          : 0.1; // Adjust emission frequency based on screen size

                      return ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: pi / 2, // Downward
                        maxBlastForce: 20 * scale,
                        minBlastForce: 10 * scale,
                        emissionFrequency: emissionFrequency,
                        numberOfParticles: (25 * scale).round(),
                        gravity: 0.1,
                        colors: const [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width < 600
                      ? 210
                      : 230, // Move up when minimized
                  left: 0,
                  right: 50,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showCorrectIcon ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[900], size: 28),
                        SizedBox(width: 5),
                        Text(
                          "Correct!",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? 16
                                : 28,
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkMatch(int currentIndex) {
    if (!_flip) {
      _flip = true;
      _previousIndex = currentIndex;
    } else {
      _flip = false;
      if (_previousIndex != currentIndex) {
        String text1 = _data[_previousIndex];
        String text2 = _data[currentIndex];
        if (isMatch(text1, text2)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() {
              _cardFlips[_previousIndex] = false;
              _cardFlips[currentIndex] = false;
              _matchedPairs++;
              _currentlyFlippedCount = 0;
              _showCorrectIcon = true;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _showCorrectIcon = false;
                });
              }
            });
            _confettiController.play(); // Celebrate match

            String matchedWord;
            if (_translations.containsKey(_data[_previousIndex])) {
              matchedWord = _data[_previousIndex]; // English → Spanish
            } else {
              matchedWord = _data[currentIndex]; // Spanish → English
            }

            if (_matchedPairs == _data.length ~/ 2) {
              _timer.cancel();
              int score = (_seconds >= 80 ? 10 : (_seconds / 120) * 10).toInt();
              showMatchPopup(matchedWord, onDismiss: () {
                showEndGameDialog(score);
                Future.delayed(Duration.zero, () {
                  Provider.of<GameData1>(context, listen: false)
                      .setTotal(score);
                });
              });
            } else {
              showMatchPopup(matchedWord);
            }
          });
        } else {
          _wait = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            _cardStateKeys[_previousIndex].currentState?.toggleCard();
            _cardStateKeys[currentIndex].currentState?.toggleCard();
            Future.delayed(const Duration(milliseconds: 160), () {
              if (!mounted) return;
              setState(() {
                _wait = false;
                _currentlyFlippedCount = 0;
              });
            });
          });
        }
      }
    }
  }

  void showEndGameDialog(int score) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;

        // Define responsive sizes
        final double titleFontSize = screenWidth < 600 ? 20 : 33;
        final double messageFontSize = screenWidth < 600 ? 18 : 29;
        final double scoreFontSize = screenWidth < 600 ? 16 : 25;
        final double buttonFontSize = screenWidth < 600 ? 16 : 25;
        final double contentPadding = screenWidth < 600 ? 16 : 30;

        return AlertDialog(
          title: Text(
            "C O N G R A T U L A T I O N S ! ! !",
            style: TextStyle(fontSize: titleFontSize),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You've Matched All Cards!",
                style: TextStyle(fontSize: messageFontSize),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text("Score: $score/10",
                  style: TextStyle(fontSize: scoreFontSize)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text("N E W  G A M E",
                        style: TextStyle(fontSize: buttonFontSize)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      restart();
                      setState(() {
                        _seconds = 120;
                        _initializeTimer();
                      });
                    },
                  ),
                  TextButton(
                    child: Text("E X I T",
                        style: TextStyle(fontSize: buttonFontSize)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(contentPadding),
        );
      },
    );
  }
  void showMatchPopup(String matchedWord, {VoidCallback? onDismiss}) {
     // baseName preserves the original case (e.g., "One", "Addition")
    final String baseName = matchedWord.replaceAll("/", "_");
    
    // Audio Logic:
    // Chapter 1 audio files are lowercase (e.g., "one.mp3").
    // Other chapters have capitalized audio files (e.g., "Addition.mp3").
    String audioName = (chapter == 1) ? baseName.toLowerCase() : baseName;

    // Image Logic:
    // Image files appear to be capitalized for both chapters (e.g., "One.png", "Addition.png").
    String fileName2 = baseName;
    if (fileName2 == "≠") fileName2 = "not_equal";

    // 1) Play tick first:
    _tickPlayer
        .play(AssetSource('Mathmingle/audio/Correct_Answer_Tick.mp3'))
        .then((_) {
      // 2) Only after tick finishes play the matchedWord audio:
      _wordPlayer.play(AssetSource('Mathmingle/audio/$audioName.mp3'));
    });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;

      // If screen height < 600, use 300×350; otherwise use 400×450.
      final dialogWidth = screenHeight < 600 ? 200.0 : 400.0;
      //final dialogHeight = screenHeight < 600 ? 300.0 : 450.0;
      final dialogHeight = screenHeight < 400
        ? 200.0
        : (screenHeight < 600 ? 300.0 : 450.0);
      //final imageHeight = screenHeight < 600 ? 100.0 : 320.0;
      final textFontSize = screenHeight < 600 ? 16.0 : 22.0;
      final partypopperHeight = screenHeight < 600 ? 20.0 : 28.0;
      final partypopperWidth = screenHeight < 600 ? 20.0 : 28.0;
      final iconsize = screenHeight < 600 ? 30.0 : 40.0;
      final matchedwordfontSize = screenHeight < 600 ? 16.0 : 22.0;

      final imageHeight = screenHeight < 400
      ? 100.0
      : (screenHeight < 600
          ? 200.0
          : 320.0);
   
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(10),
        content: SizedBox(
          width: dialogWidth,  // Set custom width
          height: dialogHeight, // Set custom height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Well done! You got it right.",
                    style: TextStyle(fontSize: textFontSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    'assets/Mathmingle/party-popper.png',
                    height: partypopperHeight,
                    width: partypopperWidth,
                  ),
                  
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: iconsize, // adjust size as needed
                  ),
                ],
              ),
             
              //const SizedBox(height: 16),
              const SizedBox(height: 8),
              
              Image.asset(
                'assets/Mathmingle/$fileName2.png',
                height: imageHeight,
                fit: BoxFit.contain,
              ),
              //const SizedBox(height: 16),
              const SizedBox(height: 8),
              Text(
                matchedWord,
                style: TextStyle(fontSize: matchedwordfontSize, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 10),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      );
    },
  ).then((_) {
      if (onDismiss != null) {
        onDismiss();
      }
    });
}

  bool isMatch(String t1, String t2) {
    return _translations[t1] == t2 || _translations[t2] == t1;
  }

  Widget getQuestionMarkCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 3,
            spreadRadius: 0.8,
            offset: Offset(2.0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/Mathmingle/question_mark.png"),
      ),
    );
  }

  List<String> getSourceArray(int chapter) {
    List<List<String>> sourceArrays = fillSourceArray(chapter);
    List<int> uniqueRandomIndices = [];
    while (uniqueRandomIndices.length < 5) {
      int r = Random().nextInt(20);
      if (!uniqueRandomIndices.contains(r)) {
        uniqueRandomIndices.add(r);
      }
    }
    List<String> levelAndKindList = [];
    for (int i = 0; i < 5; i++) {
      int index = uniqueRandomIndices[i];
      levelAndKindList.add(sourceArrays[0][index]);
      levelAndKindList.add(sourceArrays[1][index]);
    }
    levelAndKindList.shuffle();
    return levelAndKindList;
  }

  List<List<String>> fillSourceArray(int chapter) {
    List<String> englishWords = [];
    List<String> spanishWords = [];
    switch (chapter) {
      case 1:
        englishWords = [
          'one',
          'two',
          'three',
          'four',
          'five',
          'six',
          'seven',
          'eight',
          'nine',
          'ten',
          "Eleven",
          "Twelve",
          "Thirteen",
          "Fourteen",
          "Fifteen",
          "Sixteen",
          "Seventeen",
          "Eighteen",
          "Nineteen",
          "Twenty"
        ];
        spanishWords = [
          'uno',
          'dos',
          'tres',
          'cuatro',
          'cinco',
          'seis',
          'siete',
          'ocho',
          'nueve',
          'diez',
          "Once",
          "Doce",
          "Trece",
          "Catorce",
          "Quince",
          "Dieciséis",
          "Diecisiete",
          "Dieciocho",
          "Diecinueve",
          "Veinte"
        ];
        break;
      case 2:
        englishWords = [
          'Numbers',
          'Addition',
          'Subtraction',
          'Multiplication',
          'Division',
          'Equal',
          'Greater than',
          'Less than',
          'Plus',
          'Minus',
          'Times',
          'Divided by',
          'Sum',
          'Difference',
          'Product',
          'Quotient',
          'Fraction',
          'Decimal',
          'Ratio',
          'Equation'
        ];
        spanishWords = [
          'Número',
          'Adición',
          'Resta',
          'Multiplicación',
          'División',
          'Igual',
          'Mayor que',
          'Menor que',
          'Más',
          'Menos',
          'Por',
          'Dividido por',
          'Suma',
          'Diferencia',
          'Producto',
          'Cociente',
          'Fracción',
          'Decimal',
          'Proporción',
          'Ecuación'
        ];
        break;
      case 3:
        englishWords = [
          'Circle',
          'Triangle',
          'Square',
          'Rectangle',
          'Rhombus',
          'Parallelogram',
          'Trapezium',
          'Oval',
          'Ellipse',
          'Sphere',
          'Cube',
          'Cylinder',
          'Cone',
          'Pentagonal prism',
          'Hexagonal prism',
          'Pyramid',
          'Cuboid',
          'Triangular prism',
          'Hemisphere',
          'Torus'
        ];
        spanishWords = [
          'Círculo',
          'Triángulo',
          'Cuadrado',
          'Rectángulo',
          'Rombus',
          'Paralelogramo',
          'Trapecio',
          'Óvalo',
          'Elipse',
          'Esfera',
          'Cubo',
          'Cilindro',
          'Cono',
          'Prisma pentagonal',
          'Prisma hexagonal',
          'Pirámide',
          'Cuboide',
          'Prisma triangular',
          'Hemisferio',
          'Toro'
        ];
        break;
      case 4:
        englishWords = [
          '+',
          '-',
          '=',
          '>',
          '<',
          '×',
          '÷',
          '√',
          '/',
          '%',
          '^',
          '∑',
          '∫',
          'd/dx',
          '∞',
          '≠',
          '≥',
          '≤',
          '≈',
          'lim'
        ];
        spanishWords = [
          'Más',
          'Menos',
          'Igual',
          'Mayor que',
          'Menor que',
          'Por',
          'Dividido por',
          'Raíz cuadrada',
          'Fracción',
          'Porcentaje',
          'Exponenciación',
          'Sumatoria',
          'Integral',
          'Derivada',
          'Infinito',
          'No igual a',
          'Mayor o igual que',
          'Menor o igual que',
          'Aproximadamente igual a',
          'Límite'
        ];
        break;
      case 5:
        englishWords = [
          "Length",
          "Width",
          "Height",
          "Diameter",
          "Radius",
          "Perimeter",
          "Circumference",
          "Area",
          "Volume",
          "Angle",
          "Slope",
          "Intersection",
          "Symmetry",
          "Perpendicular",
          "Parallel",
          "Coordinate",
          "Vertex",
          "Axis",
          "Hypotenuse",
          "Gradient"
        ];
        spanishWords = [
          "Longitud",
          "Ancho",
          "Altura",
          "Diámetro",
          "Radio",
          "Perímetro",
          "Circunferencia",
          "Superficie",
          "Volumen",
          "Ángulo",
          "Pendiente",
          "Intersección",
          "Simetría",
          "Perpendicular",
          "Paralelo",
          "Coordenada",
          "Vértice",
          "Eje",
          "Hipotenusa",
          "Gradiente"
        ];
        break;
      default:
        englishWords = ['one', 'two'];
        spanishWords = ['uno', 'dos'];
    }
    return [englishWords, spanishWords];
  }

  Map<String, String> getTranslations(int chapter) {
    switch (chapter) {
      case 1:
        return {
          'one': 'uno',
          'two': 'dos',
          'three': 'tres',
          'four': 'cuatro',
          'five': 'cinco',
          'six': 'seis',
          'seven': 'siete',
          'eight': 'ocho',
          'nine': 'nueve',
          'ten': 'diez',
          'Eleven': 'Once',
          'Twelve': 'Doce',
          'Thirteen': 'Trece',
          'Fourteen': 'Catorce',
          'Fifteen': 'Quince',
          'Sixteen': 'Dieciséis',
          'Seventeen': 'Diecisiete',
          'Eighteen': 'Dieciocho',
          'Nineteen': 'Diecinueve',
          'Twenty': 'Veinte'
        };
      case 2:
        return {
          'Numbers': 'Número',
          'Addition': 'Adición',
          'Subtraction': 'Resta',
          'Multiplication': 'Multiplicación',
          'Division': 'División',
          'Equal': 'Igual',
          'Greater than': 'Mayor que',
          'Less than': 'Menor que',
          'Plus': 'Más',
          'Minus': 'Menos',
          'Times': 'Por',
          'Divided by': 'Dividido por',
          'Sum': 'Suma',
          'Difference': 'Diferencia',
          'Product': 'Producto',
          'Quotient': 'Cociente',
          'Fraction': 'Fracción',
          'Decimal': 'Decimal',
          'Ratio': 'Proporción',
          'Equation': 'Ecuación'
        };
      case 3:
        return {
          'Circle': 'Círculo',
          'Triangle': 'Triángulo',
          'Square': 'Cuadrado',
          'Rectangle': 'Rectángulo',
          'Rhombus': 'Rombus',
          'Parallelogram': 'Paralelogramo',
          'Trapezium': 'Trapecio',
          'Oval': 'Óvalo',
          'Ellipse': 'Elipse',
          'Sphere': 'Esfera',
          'Cube': 'Cubo',
          'Cylinder': 'Cilindro',
          'Cone': 'Cono',
          'Pentagonal prism': 'Prisma pentagonal',
          'Hexagonal prism': 'Prisma hexagonal',
          'Pyramid': 'Pirámide',
          'Cuboid': 'Cuboide',
          'Triangular prism': 'Prisma triangular',
          'Hemisphere': 'Hemisferio',
          'Torus': 'Toro'
        };
      case 4:
        return {
          '+': 'Más',
          '-': 'Menos',
          '=': 'Igual',
          '>': 'Mayor que',
          '<': 'Menor que',
          '×': 'Por',
          '÷': 'Dividido por',
          '√': 'Raíz cuadrada',
          '/': 'Fracción',
          '%': 'Porcentaje',
          '^': 'Exponenciación',
          '∑': 'Sumatoria',
          '∫': 'Integral',
          'd/dx': 'Derivada',
          '∞': 'Infinito',
          '≠': 'No igual a',
          '≥': 'Mayor o igual que',
          '≤': 'Menor o igual que',
          '≈': 'Aproximadamente igual a',
          'lim': 'Límite'
        };
      case 5:
        return {
          "Length": "Longitud",
          "Width": "Ancho",
          "Height": "Altura",
          "Diameter": "Diámetro",
          "Radius": "Radio",
          "Perimeter": "Perímetro",
          "Circumference": "Circunferencia",
          "Area": "Superficie",
          "Volume": "Volumen",
          "Angle": "Ángulo",
          "Slope": "Pendiente",
          "Intersection": "Intersección",
          "Symmetry": "Simetría",
          "Perpendicular": "Perpendicular",
          "Parallel": "Paralelo",
          "Coordinate": "Coordenada",
          "Vertex": "Vértice",
          "Axis": "Eje",
          "Hypotenuse": "Hipotenusa",
          "Gradient": "Gradiente"
        };
      default:
        return {'one': 'uno', 'two': 'dos'};
    }
  }
}

class ClockDisplay extends StatelessWidget {
  final int seconds;
  const ClockDisplay({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the width based on screen size
            double containerWidth = constraints.maxWidth > 600
                ? 350 // Set a fixed width of 350 when screen is maximized
                : constraints.maxWidth *
                    0.5; // Scale width to 50% of available screen width when minimized

            return Container(
              width: containerWidth,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[400], // Light grey
              ),
              alignment: Alignment.center,
              child: Text(
                '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}