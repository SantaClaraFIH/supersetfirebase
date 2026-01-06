import 'package:flutter/material.dart';
import 'games/even_odd_sort.dart';
import 'games/choose_factors_game.dart';
import 'games/word_problem_game.dart';
import 'games/prime_number_game.dart';
import 'games/number_pattern_match_game.dart';
import 'games/Match_LCM.dart';
import 'games/Squares_Game.dart';
import 'analytics_engine.dart'; // Import analytics engine

class GameListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Log module navigation when games page is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('games');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("GAMES"),
      ),
      body: Container(
        decoration: BoxDecoration(
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
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GameButton(
                      title: 'Choose Factors\nGame',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Choose Factors Game');
                        AnalyticsEngine.logGameStart('choose_factors');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DartGamePage()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'Perfect Square\nGame',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Perfect Square Game');
                        AnalyticsEngine.logGameStart('perfect_square');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PerfectSquareFinder()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'Number Pattern\nMatch',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Number Pattern Match');
                        AnalyticsEngine.logGameStart('pattern_match');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NumberPatternMatchGame()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'Even-Odd Sort\nGame',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Even-Odd Sort Game');
                        AnalyticsEngine.logGameStart('even_odd_sort');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EvenOddSortPage()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'Triangle Tower\nBuilder',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Triangle Tower Builder');
                        AnalyticsEngine.logGameStart('triangle_tower');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WordProblemsGame()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'Prime Explorer',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'Prime Explorer');
                        AnalyticsEngine.logGameStart('prime_explorer');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PrimeNumberGame()),
                        );
                      },
                    ),
                    GameButton(
                      title: 'LCM Match',
                      onPressed: () {
                        // Log content selection and game start
                        AnalyticsEngine.logContentSelection('game', 'LCM Match');
                        AnalyticsEngine.logGameStart('lcm_match');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LCMGame()),
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

  GameButton({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 400 ? 18 : 24;

    return Container(
      padding: EdgeInsets.all(10),
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