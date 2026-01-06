import 'package:flutter/material.dart';
import 'lessons/even_number_info_page.dart';
import 'lessons/odd_number_info_page.dart';
import 'lessons/prime_number_info_page.dart';
import 'lessons/composite_number_info_page.dart';
import 'lessons/triangular_number_info_page.dart';
import 'lessons/perfect_number_info_page.dart';
import 'lessons/square_number_info_page.dart';
import 'lessons/fibonacci_number_info_page.dart';
import 'lessons/factors_info_page.dart';
import 'lessons/cube_number_info_page.dart';
import 'analytics_engine.dart';

class LessonsPage extends StatelessWidget {
  final List<Map<String, dynamic>> lessons = [
    {'title': 'Even Numbers', 'page': EvenNumberInfoPage()},
    {'title': 'Odd Numbers', 'page': OddNumberInfoPage()},
    {'title': 'Prime Numbers', 'page': PrimeNumberInfoPage()},
    {'title': 'Composite Numbers', 'page': CompositeNumberInfoPage()},
    {'title': 'Triangular Numbers', 'page': TriangularNumberInfoPage()},
    {'title': 'Perfect Numbers', 'page': PerfectNumberInfoPage()},
    {'title': 'Square Numbers', 'page': SquareNumberInfoPage()},
    {'title': 'Fibonacci Numbers', 'page': FibonacciNumberInfoPage()},
    {'title': 'Factors', 'page': FactorsInfoPage()},
    {'title': 'Cube Numbers', 'page': CubeNumberInfoPage()},
  ];

  @override
  Widget build(BuildContext context) {
    // Log module navigation when lessons page is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('lessons');
       print('A Lesson in modules is logged');
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('LESSON PLAN'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/MathNumQuest/lesson_page.jpeg'),
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
                  children: lessons.map((lesson) {
                    return LessonButton(
                      title: lesson['title'],
                      onPressed: () {
                        String lessonType = AnalyticsEngine.getLessonTypeFromContext(lesson['title']);
                        AnalyticsEngine.logContentSelection('lesson', lesson['title']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => lesson['page']),
                        );
                      },
                    );
                  }).toList(),
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
