import 'package:flutter/material.dart';
import 'analytics_engine.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'language_switcher.dart';
import 'language_provider.dart';
import 'total_xp_display.dart';
import 'total_xp_provider.dart';

class ImportanceOfEquations extends StatefulWidget {
  const ImportanceOfEquations({super.key});

  @override
  _ImportanceOfEquationsState createState() => _ImportanceOfEquationsState();
}

class _ImportanceOfEquationsState extends State<ImportanceOfEquations> {
  final Map<String, String> englishText = {
    'title': 'Importance of Equations',
    'foundation':
        '- Foundation of Mathematics: Equations are a fundamental part of mathematics, forming the basis for more complex concepts and calculations.',
    'problemSolving':
        '- Problem-Solving Skills: Learning to solve equations enhances your problem-solving abilities, allowing you to tackle various types of mathematical problems.',
    'realWorld':
        '- Real-World Applications: Equations are used in everyday life, from calculating distances and expenses to understanding scientific phenomena.',
    'logicalThinking':
        '- Logical Thinking: Working with equations helps develop logical thinking and reasoning skills, which are valuable in many aspects of life and other subjects.',
    'predictivePower':
        '- Predictive Power: Equations enable us to predict outcomes and understand relationships between different variables, which is essential in science and engineering.',
    'higherEducation':
        '- Critical for Higher Education: Mastering equations is crucial for success in higher-level math courses and STEM (Science, Technology, Engineering, and Mathematics) fields.',
    'confidence':
        '- Boosts Confidence: Successfully solving equations boosts your confidence and encourages a positive attitude towards learning mathematics.',
  };

  final Map<String, String> spanishText = {
    'title': 'Importancia de las Ecuaciones',
    'foundation':
        '- Fundamento de las Matemáticas: Las ecuaciones son una parte fundamental de las matemáticas, formando la base para conceptos y cálculos más complejos.',
    'problemSolving':
        '- Habilidades para Resolver Problemas: Aprender a resolver ecuaciones mejora tus habilidades para resolver problemas, permitiéndote abordar varios tipos de problemas matemáticos.',
    'realWorld':
        '- Aplicaciones en el Mundo Real: Las ecuaciones se utilizan en la vida cotidiana, desde calcular distancias y gastos hasta comprender fenómenos científicos.',
    'logicalThinking':
        '- Pensamiento Lógico: Trabajar con ecuaciones ayuda a desarrollar habilidades de pensamiento lógico y razonamiento, que son valiosas en muchos aspectos de la vida y otras materias.',
    'predictivePower':
        '- Poder Predictivo: Las ecuaciones nos permiten predecir resultados y comprender las relaciones entre diferentes variables, lo cual es esencial en la ciencia y la ingeniería.',
    'higherEducation':
        '- Crítico para la Educación Superior: Dominar las ecuaciones es crucial para el éxito en cursos de matemáticas de nivel superior y campos STEM (Ciencia, Tecnología, Ingeniería y Matemáticas).',
    'confidence':
        '- Aumenta la Confianza: Resolver ecuaciones con éxito aumenta tu confianza y fomenta una actitud positiva hacia el aprendizaje de las matemáticas.',
  };

  @override
  Widget build(BuildContext context) {
    final isSpanish = Provider.of<LanguageProvider>(context).isSpanish;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;
    final text = isSpanish ? spanishText : englishText;
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'PIN: $userPin',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen =
              constraints.maxWidth > 600; // Check if the screen is wide
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: isWideScreen
                    ? constraints.maxWidth *
                        0.7 // Use 60% width for wide screens
                    : constraints.maxWidth *
                        0.8, // Use 80% width for smaller screens
                child: SingleChildScrollView(
                  // Added to prevent overflow
                  child: IntrinsicHeight(
                    child: Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text['title']!,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._buildTextSections(text),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // Logout button (bottom right)
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

  List<Widget> _buildTextSections(Map<String, String> text) {
    return text.entries
        .where((entry) => entry.key != 'title') // Exclude the title
        .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 18),
              ),
            ))
        .toList();
  }
}
