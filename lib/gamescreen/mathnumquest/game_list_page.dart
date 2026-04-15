import 'package:flutter/material.dart';
import 'games/even_odd_sort.dart';
import 'games/choose_factors_game.dart';
import 'games/word_problem_game.dart';
import 'games/prime_number_game.dart';
import 'games/number_pattern_match_game.dart';
import 'games/Match_LCM.dart';
import 'games/Squares_Game.dart';
import 'analytics_engine.dart'; // Import analytics engine

class GameListPage extends StatefulWidget {
  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  bool isEnglish = true;

  String t(String en, String es) => isEnglish ? en : es;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('games');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(t("GAMES", "JUEGOS")),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
              });
            },
            //icon: const Icon(Icons.translate, color: Colors.white),
            label: Text(
              isEnglish ? "Tap to Translate" : "Toca para Traducir",
              style: const TextStyle(color: Colors.orange, fontSize: 20,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            int crossAxisCount = 1;
            double horizontalPadding = 20;

            if (screenWidth >= 1200) {
              crossAxisCount = 4;
              horizontalPadding = 100;
            } else if (screenWidth >= 800) {
              crossAxisCount = 3;
              horizontalPadding = 60;
            } else if (screenWidth >= 600) {
              crossAxisCount = 2;
              horizontalPadding = 40;
            } else {
              crossAxisCount = 1;
              horizontalPadding = 20;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 50),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GameButton(
                      title: t('Choose Factors\nGame', 'Elige Factores\nJuego'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Choose Factors Game');
                        AnalyticsEngine.logGameStart('choose_factors');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DartGamePage(isEnglish: isEnglish)),
                        );
                      },
                    ),
                    GameButton(
                      title: t('Perfect Square\nGame', 'Juego de\nCuadrado Perfecto'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Perfect Square Game');
                        AnalyticsEngine.logGameStart('perfect_square');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SquareFinderGame(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                    GameButton(
                      title: t('Number Pattern\nMatch', 'Coincidencia de\nPatrones Numéricos'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Number Pattern Match');
                        AnalyticsEngine.logGameStart('pattern_match');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NumberPatternMatchGame(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                    GameButton(
                      title: t('Even-Odd Sort\nGame', 'Juego de\nNúmeros Pares e Impares'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Even-Odd Sort Game');
                        AnalyticsEngine.logGameStart('even_odd_sort');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EvenOddSortPage(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                    GameButton(
                      title: t('Triangle Tower\nBuilder', 'Constructor de\nTorres Triangulares'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Triangle Tower Builder');
                        AnalyticsEngine.logGameStart('triangle_tower');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordProblemsGame(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                    GameButton(
                      title: t('Prime Explorer', 'Explorador de\nNúmeros Primos'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'Prime Explorer');
                        AnalyticsEngine.logGameStart('prime_explorer');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrimeNumberGrid(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                    GameButton(
                      title: t('LCM Match', 'Coincidencia de MCM'),
                      onPressed: () {
                        AnalyticsEngine.logContentSelection('game', 'LCM Match');
                        AnalyticsEngine.logGameStart('lcm_match');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LCMGamePage(isEnglish: isEnglish),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  final String title;
  final Function()? onPressed;

  const GameButton({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 400 ? 18 : 24;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.cyan.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}