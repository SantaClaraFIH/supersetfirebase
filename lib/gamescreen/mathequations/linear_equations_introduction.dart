import 'package:flutter/material.dart';
import 'analytics_engine.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'total_xp_display.dart';
import 'total_xp_provider.dart';
import 'language_switcher.dart';
import 'language_provider.dart';

class LinearEquationsIntroduction extends StatefulWidget {
  const LinearEquationsIntroduction({super.key});

  @override
  _LinearEquationsIntroductionState createState() =>
      _LinearEquationsIntroductionState();
}

class _LinearEquationsIntroductionState
    extends State<LinearEquationsIntroduction> {
  String? selectedAnswer;
  bool showAnswer = false;

  final Map<String, String> englishText = {
    'title': 'Linear Equations',
    'definitionTitle': 'Definition of Linear Equations',
    'definition':
        'Linear equations are algebraic equations that describe a straight line relationship between variables. They are called "linear" because the highest power of the variable is 1. In general, a linear equation takes the form: Ax + By + C = 0, where A, B, and C are constants, and x and y are variables.',
    'standardFormTitle': 'Standard Form (Ax + B = C)',
    'standardForm':
        'The standard form of a linear equation is Ax + By = C, where A, B, and C are constants, and A and B are not both zero. This form is useful for graphing linear equations and finding their intercepts.',
    'slopeInterceptFormTitle': 'Slope-Intercept Form (y = mx + b)',
    'slopeInterceptForm':
        'The slope-intercept form of a linear equation is y = mx + b, where m is the slope of the line and b is the y-intercept (the point where the line crosses the y-axis). This form is convenient for graphing linear equations and determining the slope and y-intercept.',
    'examplesTitle': 'Examples of Linear Equations',
    'examples':
        '1. 2x + 3y = 7\n2. -5x + 4y = -12\n3. 3x - 6y = 18\n4. 4x + y = 10\n5. -2x - 5y = -15\n',
    'quizTitle': 'Quiz:',
    'quizQuestion': 'What is the slope-intercept form of a linear equation?',
    'correctAnswer': 'Correct! The slope-intercept form is y = mx + b.',
    'incorrectAnswer': 'Incorrect. The slope-intercept form is y = mx + b.',
  };

  final Map<String, String> spanishText = {
    'title': 'Ecuaciones Lineales',
    'definitionTitle': 'Definición de Ecuaciones Lineales',
    'definition':
        'Las ecuaciones lineales son ecuaciones algebraicas que describen una relación lineal entre variables. Se llaman "lineales" porque la mayor potencia de la variable es 1. En general, una ecuación lineal toma la forma: Ax + By + C = 0, donde A, B y C son constantes, y x e y son variables.',
    'standardFormTitle': 'Forma Estándar (Ax + B = C)',
    'standardForm':
        'La forma estándar de una ecuación lineal es Ax + By = C, donde A, B y C son constantes, y A y B no son ambos cero. Esta forma es útil para graficar ecuaciones lineales y encontrar sus intersecciones.',
    'slopeInterceptFormTitle': 'Forma Pendiente-Intersección (y = mx + b)',
    'slopeInterceptForm':
        'La forma pendiente-intersección de una ecuación lineal es y = mx + b, donde m es la pendiente de la línea y b es la intersección con el eje y (el punto donde la línea cruza el eje y). Esta forma es conveniente para graficar ecuaciones lineales y determinar la pendiente y la intersección con el eje y.',
    'examplesTitle': 'Ejemplos de Ecuaciones Lineales',
    'examples':
        '1. 2x + 3y = 7\n2. -5x + 4y = -12\n3. 3x - 6y = 18\n4. 4x + y = 10\n5. -2x - 5y = -15\n',
    'quizTitle': 'Cuestionario:',
    'quizQuestion':
        '¿Cuál es la forma pendiente-intersección de una ecuación lineal?',
    'correctAnswer':
        '¡Correcto! La forma pendiente-intersección es y = mx + b.',
    'incorrectAnswer':
        'Incorrecto. La forma pendiente-intersección es y = mx + b.',
  };

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showAnswer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = Provider.of<LanguageProvider>(context).isSpanish;
    final text = isSpanish ? spanishText : englishText;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    return Scaffold(
      appBar: AppBar(
        title: Text(text['title']!),
        actions: [
          LanguageSwitcher(
            isSpanish: isSpanish,
            onLanguageChanged: (bool newIsSpanish) {
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLanguage(newIsSpanish);
              AnalyticsEngine.logTranslateButtonClickLearn(
                  newIsSpanish ? 'Changed to Spanish' : 'Changed to English');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TotalXpDisplay(totalXp: totalXp),
          ),
          Text(
            'PIN: $userPin',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 8,
            color: const Color(0xFFFEFFD2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text['definitionTitle']!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      text['definition']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      text['standardFormTitle']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      text['standardForm']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      text['slopeInterceptFormTitle']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      text['slopeInterceptForm']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      text['examplesTitle']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      text['examples']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            text['quizTitle']!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            text['quizQuestion']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => checkAnswer('y = mx + b'),
                            style: ButtonStyle(
                              backgroundColor: selectedAnswer == 'y = mx + b'
                                  ? WidgetStateProperty.all(Colors.green)
                                  : null,
                            ),
                            child: const Text('y = mx + b'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => checkAnswer('Ax + By = C'),
                            style: ButtonStyle(
                              backgroundColor: selectedAnswer == 'Ax + By = C'
                                  ? WidgetStateProperty.all(Colors.red)
                                  : null,
                            ),
                            child: const Text('Ax + By = C'),
                          ),
                        ],
                      ),
                    ),
                    if (showAnswer)
                      Center(
                        child: Text(
                          selectedAnswer == 'y = mx + b'
                              ? text['correctAnswer']!
                              : text['incorrectAnswer']!,
                          style: TextStyle(
                            fontSize: 18,
                            color: selectedAnswer == 'y = mx + b'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'equations_logout',
        onPressed: () => logout(context),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.logout_rounded,
          color: Colors.black,
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
