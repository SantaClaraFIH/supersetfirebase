import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/MultipageContainer.dart';
import 'package:num_quest/FlashCards/SquaresPracticePage.dart';
import '../analytics_engine.dart';

class SquareNumberInfoPage extends StatefulWidget {
  @override
  _SquareNumberInfoPageState createState() => _SquareNumberInfoPageState();
}

class _SquareNumberInfoPageState extends State<SquareNumberInfoPage> {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> lessonData = [];
  final String lessonType = 'square_numbers';

  Future<void> loadLessonData() async {
    final String jsonData =
        await rootBundle.loadString('assets/squarenum_lesson.json');
    setState(() {
      lessonData = json.decode(jsonData)['pages'];
    });
  }

  Future<void> speak(String text, bool isEnglish) async {
    await flutterTts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
    final String language = AnalyticsEngine.getLanguageString(isEnglish);
    AnalyticsEngine.logAudioButtonClickLessons(language, lessonType);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }

  void _onQuizPressed() {
    stopSpeaking();
    AnalyticsEngine.logLessonCompletion(lessonType);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PerfectSquareFinder()),
    );
  }

  @override
  void dispose() {
    stopSpeaking();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadLessonData();
  }

  @override
  Widget build(BuildContext context) {
    if (lessonData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultipageContainer(
      lessonType: lessonType,
      pages: List<Widget Function(bool)>.generate(lessonData.length, (index) {
        final Map<String, dynamic> page = lessonData[index];
        return (bool isEnglish) {
          final langData = isEnglish ? page['english'] : page['spanish'];
          final String summary = langData['text'] ?? '';
          final String description = langData['description'] ?? '';
          final String title = langData['title'] ?? '';
          final List<String> keyIdeas = List<String>.from(langData['keyIdeas'] ?? []);
          final List<String> highlightNumbers = List<String>.from(page['highlightNumbers'] ?? []);
          final String imageCaption = langData['imageCaption'] ?? '';
          final String callout = langData['callout'] ?? '';
          final String extraDetail = langData['extraDetail'] ?? '';

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 900;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey('${isEnglish ? 'en' : 'es'}-$index'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCalloutBanner(callout),
                    const SizedBox(height: 20),
                    _buildHeroCard(
                      title: title,
                      summary: summary,
                      description: description,
                      extraDetail: extraDetail,
                      listenLabel: isEnglish ? 'Listen' : 'Escuchar',
                      onPlay: () {
                        stopSpeaking();
                        speak(summary, isEnglish);
                      },
                    ),
                    const SizedBox(height: 24),
                    Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoPanel(
                            heading: isEnglish ? 'Key ideas' : 'Ideas clave',
                            icon: Icons.crop_square,
                            color: Colors.blue,
                            bullets: keyIdeas,
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 24 : 0,
                          height: isWide ? 0 : 24,
                        ),
                        Expanded(
                          child: _buildImagePanel(
                            imagePath: page['image'],
                            caption: imageCaption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildNumberShowcase(
                      title: isEnglish
                          ? 'Square number spotlight'
                          : 'Números cuadrados destacados',
                      numbers: highlightNumbers,
                    ),
                    if (index == lessonData.length - 1) ...[
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.center,
                        child: FilledButton.icon(
                          onPressed: _onQuizPressed,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(Icons.quiz, color: Colors.white),
                          label: Text(
                            isEnglish ? 'Start quiz' : 'Comenzar quiz',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        };
      }),
    );
  }

  Widget _buildCalloutBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400D47A1),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.crop_square, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String title,
    required String summary,
    required String description,
    required String extraDetail,
    required String listenLabel,
    required VoidCallback onPlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331976D2),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.crop_square,
                  color: Color(0xFF0D47A1), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onPlay,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: Text(
                  listenLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 20,
              height: 1.5,
              color: Color(0xFF0D47A1),
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildHighlightedParagraph(description),
          ],
          if (extraDetail.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              extraDetail,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightedParagraph(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0D47A1).withOpacity(0.2),
          width: 1.4,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildInfoPanel({
    required String heading,
    required IconData icon,
    required Color color,
    required List<String> bullets,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _darken(color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 10, color: color.withOpacity(0.7)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: _darken(color, 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePanel({
    required String imagePath,
    required String caption,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33213A5C),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Color(0xFF2D3142),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberShowcase({
    required String title,
    required List<String> numbers,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330D47A1),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: numbers
                .map(
                  (number) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4042A5F5),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color, [double amount = 0.1]) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final double lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

