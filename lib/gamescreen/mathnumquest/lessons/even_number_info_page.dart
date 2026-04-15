import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/MultipageContainer.dart';
import 'practice_even.dart';
import '../analytics_engine.dart';

class EvenNumberInfoPage extends StatefulWidget {
  @override
  _EvenNumberInfoPageState createState() => _EvenNumberInfoPageState();
}

class _EvenNumberInfoPageState extends State<EvenNumberInfoPage> {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> lessonData = [];
  final String lessonType = 'even_numbers';

  Future<void> loadLessonData() async {
    final String jsonData =
        await rootBundle.loadString('assets/even_lessons.json');
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
      MaterialPageRoute(builder: (context) => WordProblemPractice()),
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
          final List<String> pairSteps = List<String>.from(langData['pairSteps'] ?? []);

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
                    if (index == 0) ...[
                      _buildInfoPanel(
                        heading: isEnglish ? 'Key ideas' : 'Ideas clave',
                        icon: Icons.auto_awesome,
                        color: Colors.indigo,
                        bullets: keyIdeas,
                      ),
                      const SizedBox(height: 24),
                      _buildVisualPanel(
                        pageIndex: index,
                        imagePath: page['image'],
                        caption: imageCaption,
                        isEnglish: isEnglish,
                        pairSteps: pairSteps,
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInfoPanel(
                              heading: isEnglish ? 'Key ideas' : 'Ideas clave',
                              icon: Icons.auto_awesome,
                              color: Colors.indigo,
                              bullets: keyIdeas,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 24 : 0,
                            height: isWide ? 0 : 24,
                          ),
                          Expanded(
                            child: _buildVisualPanel(
                              pageIndex: index,
                              imagePath: page['image'],
                              caption: imageCaption,
                              isEnglish: isEnglish,
                              pairSteps: pairSteps,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildNumberShowcase(
                      title: isEnglish
                          ? 'Even number spotlight'
                          : 'Números pares destacados',
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
          colors: [Color(0xFF6C63FF), Color(0xFF7F53AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40211E72),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb, color: Colors.white),
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
          colors: [Color(0xFFB3FFAB), Color(0xFF12FFF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33219D8E),
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
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF0E3055), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E3055),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onPlay,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3055),
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
              color: Color(0xFF0E3055),
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildHighlightedParagraph(description),
          ],
          const SizedBox(height: 16),
          Text(
            extraDetail,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Color(0xFF0E3055),
              fontWeight: FontWeight.w500,
            ),
          ),
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
          color: const Color(0xFF0E3055).withOpacity(0.2),
          width: 1.4,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          color: Color(0xFF0E3055),
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

  Widget _buildVisualPanel({
    required int pageIndex,
    required String imagePath,
    required String caption,
    required bool isEnglish,
    required List<String> pairSteps,
  }) {
    if (pageIndex == 0) {
      return _buildCandyPanel(
        imagePath: imagePath,
        caption: caption,
        steps: pairSteps,
        isEnglish: isEnglish,
      );
    }

    return _buildImagePanel(imagePath: imagePath, caption: caption);
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

  Widget _buildCandyPanel({
    required String imagePath,
    required String caption,
    required List<String> steps,
    required bool isEnglish,
  }) {
    int selectedCandies = 6;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final bool isEven = selectedCandies % 2 == 0;
        final int lonelyIndex = isEven ? -1 : selectedCandies - 1;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FF7EB9),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish
                    ? 'Watch the pairs grow'
                    : 'Observa cómo crecen las parejas',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A0A3C),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool layoutWide = constraints.maxWidth > 640;
                  return Flex(
                    direction: layoutWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F3A0A3C),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish
                                    ? 'Slide to choose how many candies we share'
                                    : 'Desliza para elegir cuántos caramelos compartimos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3A0A3C),
                                ),
                              ),
                              Slider(
                                value: selectedCandies.toDouble(),
                                min: 2,
                                max: 12,
                                divisions: 10,
                                label: '$selectedCandies',
                                onChanged: (value) {
                                  setLocalState(() {
                                    selectedCandies = value.round();
                                  });
                                },
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  selectedCandies,
                                  (index) => _buildCandyToken(
                                    index: index,
                                    isEven: isEven,
                                    isLonely: index == lonelyIndex,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isEven
                                      ? const Color(0x3328A745)
                                      : const Color(0x33C62828),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isEven
                                          ? Icons.celebration
                                          : Icons.help_outline,
                                      color: isEven
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        isEven
                                            ? (isEnglish
                                                ? 'Perfect match! Every candy has a buddy.'
                                                : '¡Pareja perfecta! Cada caramelo tiene un compañero.')
                                            : (isEnglish
                                                ? 'One candy is left out. Try moving the slider to an even number.'
                                                : 'Un caramelo quedó solo. Mueve el control a un número par.'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isEven
                                              ? const Color(0xFF1B5E20)
                                              : const Color(0xFF8E0000),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: layoutWide ? 18 : 0,
                        height: layoutWide ? 0 : 18,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(12),
                            child: AspectRatio(
                              aspectRatio: layoutWide ? 4 / 3 : 16 / 9,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.asset(imagePath),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ...steps.map(
                (step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Color(0xFF402F4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Color(0xFF3A0A3C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberShowcase({
    required String title,
    required List<String> numbers,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101935).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33101935),
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
                        colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40ED8F03),
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

  Widget _buildCandyToken({
    required int index,
    required bool isEven,
    required bool isLonely,
  }) {
    final Color baseColor =
        isLonely ? const Color(0xFFFF8A80) : const Color(0xFF81C784);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            baseColor,
            baseColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isLonely ? const Color(0xFFD32F2F) : Colors.white,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33212121),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EvenNumberInfoPage(),
  ));
}
