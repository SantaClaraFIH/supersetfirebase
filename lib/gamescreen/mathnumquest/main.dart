import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'analytics_engine.dart';
import 'package:num_quest/FlashCards/practice_page.dart';
import 'game_list_page.dart';
import 'lessons_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AnalyticsEngine.init();

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isEnglish = true;

  String t(String en, String es) => isEnglish ? en : es;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/start_page.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark gradient overlay
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

          // 🔤 Tap to Translate button (top-right)
          Positioned(
            top: 40,
            right: 20,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  isEnglish = !isEnglish;
                });
              },
              //icon: const Icon(Icons.translate, color: Colors.white),
              label: Text(
                isEnglish ? 'Tap to Translate' : 'Toca para Traducir',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
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
                          shadows: const [
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
        text: t('LESSONS', 'LECCIONES'),
        color: Colors.blueAccent,
        isSmallScreen: isSmallScreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonsPage(),
            ),
          );
        },
      ),
      SizedBox(width: isSmallScreen ? 0 : 30, height: isSmallScreen ? 20 : 0),
      GameButton(
        text: t('PRACTICE', 'PRÁCTICA'),
        color: Colors.greenAccent.shade700,
        isSmallScreen: isSmallScreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PracticePage(),
            ),
          );
        },
      ),
      SizedBox(width: isSmallScreen ? 0 : 30, height: isSmallScreen ? 20 : 0),
      GameButton(
        text: t('PLAY', 'JUGAR'),
        color: Colors.deepOrangeAccent,
        isSmallScreen: isSmallScreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameListPage(),
            ),
          );
        },
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
    super.key,
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