import 'package:flutter/material.dart';
import 'PrimeNumberExamplesPage.dart';
import 'EvenNumberExamplesPage.dart';
import 'SquaresPracticePage.dart';
import 'CompositeNumberPracticePage.dart';
import 'PerfectNumbersPracticePage.dart';
import 'CubeNumberInfoPage.dart';
import 'FactorsNumberInfoPage.dart';
import '../analytics_engine.dart'; 

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}
class _PracticePageState extends State<PracticePage> {
  bool isEnglish = true;

  String t(String en, String es) => isEnglish ? en : es;

  @override
  Widget build(BuildContext context) {
    // Log module navigation when practice page is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('practice');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(t("PRACTICE", "PRÁCTICA")),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
              });
            },
            label: Text(
              isEnglish ? "Tap to Translate" : "Toca para Traducir",
              style: const TextStyle(color: Colors.orange, fontSize: 20,fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
                    LessonButton(
                      title: t('ODD & EVEN\nNUMBERS', 'NÚMEROS\nIMPARES & PARES'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'ODD & EVEN NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EvenNumberExamplesPage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('PRIME\nNUMBERS', 'NÚMEROS\nPRIMOS'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'PRIME NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrimeNumberPracticePage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('COMPOSITE\nNUMBERS', 'NÚMEROS\nCOMPUESTOS'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'COMPOSITE NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CompositeNumberPracticePage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('PERFECT\nNUMBERS', 'NÚMEROS\nPERFECTOS'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'PERFECT NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PerfectNumberPracticePage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('SQUARE\nNUMBERS', 'NÚMEROS\nCUADRADOS'), 
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'SQUARE NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PerfectSquareFinder()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('FACTORS', 'FACTORES'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'FACTORS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FactorsPracticePage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('CUBE\nNUMBERS', 'NÚMEROS\nCÚBICOS'),
                      onPressed: () {
                        // Log content selection before navigation
                        AnalyticsEngine.logContentSelection('practice', 'CUBE NUMBERS');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CubesExamplePage()),
                        );
                      },
                    ),
                    LessonButton(
                      title: t('MODULO\nNUMBERS', 'NÚMEROS\nMÓDULO'),
                      onPressed: () {
                        // Log content selection before navigation
                       // AnalyticsEngine.logContentSelection('practice', 'MODULO NUMBERS');
                        
                        // Future Implementation
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

class LessonButton extends StatelessWidget {
  final String title;
  final Function()? onPressed;

 const LessonButton({required this.title, this.onPressed});

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