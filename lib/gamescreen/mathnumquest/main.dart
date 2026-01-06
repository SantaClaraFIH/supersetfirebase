import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'analytics_engine.dart';
import 'package:supersetfirebase/gamescreen/mathnumquest/FlashCards/practice_page.dart';
import 'game_list_page.dart';
import 'lessons_page.dart';
import 'package:supersetfirebase/screens/teens_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AnalyticsEngine.init();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NumQuestPage(),
  ));
}

class NumQuestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TeensPage()),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/MathNumQuest/start_page.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.orange, Colors.yellowAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'NUMQUEST',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 60 : 100,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                              offset: Offset(3, 3),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 50),
                    if (isSmallScreen)
                      Column(children: _buildButtons(context, isSmallScreen))
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildButtons(context, isSmallScreen),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context, bool isSmallScreen) {
    return [
      GameButton(
        text: 'LESSONS',
        color: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  LessonsPage()),
          );
        },
        isSmallScreen: isSmallScreen,
      ),
      SizedBox(width: isSmallScreen ? 0 : 30, height: isSmallScreen ? 20 : 0),
      GameButton(
        text: 'PRACTICE',
        color: Colors.greenAccent.shade700,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  PracticePage()),
          );
        },
        isSmallScreen: isSmallScreen,
      ),
      SizedBox(width: isSmallScreen ? 0 : 30, height: isSmallScreen ? 20 : 0),
      GameButton(
        text: 'PLAY',
        color: Colors.deepOrangeAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  GameListPage()),
          );
        },
        isSmallScreen: isSmallScreen,
      ),
    ];
  }
}

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSmallScreen;
  final Color color;

  const GameButton({
    required this.text,
    required this.onPressed,
    required this.isSmallScreen,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black54,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14.0 : 22.0,
            horizontal: isSmallScreen ? 28.0 : 40.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
