import 'package:flutter/material.dart';
import 'PrimeNumberExamplesPage.dart';
import 'EvenNumberExamplesPage.dart';
import 'SquaresPracticePage.dart';
import 'CompositeNumberPracticePage.dart';
import 'PerfectNumbersPracticePage.dart';
import 'CubeNumberInfoPage.dart';
import 'FactorsNumberInfoPage.dart';
import '../analytics_engine.dart'; 

class PracticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Log module navigation when practice page is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('practice');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("PRACTICE"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/MathNumQuest/background1.jpg'),
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
                      title: 'ODD & EVEN\nNUMBERS',
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
                      title: 'PRIME\nNUMBERS',
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
                      title: 'COMPOSITE\nNUMBERS',
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
                      title: 'PERFECT\nNUMBERS',
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
                      title: 'SQUARE\nNUMBERS',
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
                      title: 'FACTORS',
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
                      title: 'CUBE\nNUMBERS',
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
                      title: 'MODULO\nNUMBERS',
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

  LessonButton({required this.title, this.onPressed});

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