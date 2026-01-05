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

class LessonsPage extends StatefulWidget {
  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  bool isEnglish = true;

  String t(String en, String es) => isEnglish ? en : es;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsEngine.logModuleNavigation('lessons');
      print('A Lesson in modules is logged');
    });

    final List<Map<String, dynamic>> lessons = [
      {'title': t('Even Numbers', 'Números Pares'), 'page': EvenNumberInfoPage()},
      {'title': t('Odd Numbers', 'Números Impares'), 'page': OddNumberInfoPage()},
      {'title': t('Prime Numbers', 'Números Primos'), 'page': PrimeNumberInfoPage()},
      {'title': t('Composite Numbers', 'Números Compuestos'), 'page': CompositeNumberInfoPage()},
      {'title': t('Triangular Numbers', 'Números Triangulares'), 'page': TriangularNumberInfoPage()},
      {'title': t('Perfect Numbers', 'Números Perfectos'), 'page': PerfectNumberInfoPage()},
      {'title': t('Square Numbers', 'Números Cuadrados'), 'page': SquareNumberInfoPage()},
      {'title': t('Fibonacci Numbers', 'Números Fibonacci'), 'page': FibonacciNumberInfoPage()},
      {'title': t('Factors', 'Factores'), 'page': FactorsInfoPage()},
      {'title': t('Cube Numbers', 'Números Cúbicos'), 'page': CubeNumberInfoPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('LESSON PLAN', 'PLAN DE LECCIONES')),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/lesson_page.jpeg'),
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
                  children: lessons.map((lesson) {
                    return LessonButton(
                      title: lesson['title'],
                      onPressed: () {
                        String lessonType = AnalyticsEngine.getLessonTypeFromContext(lesson['title']);
                        AnalyticsEngine.logContentSelection('lesson', lesson['title']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => lesson['page']),
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
