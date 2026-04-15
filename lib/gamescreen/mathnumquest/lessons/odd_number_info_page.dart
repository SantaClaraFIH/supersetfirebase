import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/MultipageContainer.dart';
import 'practice_odd.dart';
import '../analytics_engine.dart';

class OddNumberInfoPage extends StatefulWidget {
  @override
  _OddNumberInfoPageState createState() => _OddNumberInfoPageState();
}

class _OddNumberInfoPageState extends State<OddNumberInfoPage> {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> lessonData = [];
  final String lessonType = 'odd_numbers';

  Future<void> loadLessonData() async {
    final String jsonData =
        await rootBundle.loadString('assets/odd_lessons.json');
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
                        color: Colors.deepPurple,
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
                              color: Colors.deepPurple,
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
                          ? 'Odd number spotlight'
                          : 'Números impares destacados',
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
          colors: [Color(0xFF8E44AD), Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x408E44AD),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Colors.white),
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
          colors: [Color(0xFFE5B2CA), Color(0xFFB8C0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x338E44AD),
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
                  color: Color(0xFF311B92), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF311B92),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onPlay,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF311B92),
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
              color: Color(0xFF311B92),
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
              color: Color(0xFF311B92),
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
          color: const Color(0xFF311B92).withOpacity(0.2),
          width: 1.4,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          color: Color(0xFF311B92),
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
        color: Colors.white.withOpacity(0.9),
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
      return _buildOddCandyPanel(
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
            color: Color(0x338E44AD),
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

  Widget _buildOddCandyPanel({
    required String imagePath,
    required String caption,
    required List<String> steps,
    required bool isEnglish,
  }) {
    int selectedCandies = 5;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final bool isOdd = selectedCandies % 2 == 1;
        final int lonelyIndex = isOdd ? selectedCandies - 1 : -1;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD6E0), Color(0xFFCBC3E3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33A569BD),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'Spot the odd one out' : 'Encuentra al impar',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3F1D6B),
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
                                color: Color(0x1F3F1D6B),
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
                                    ? 'Slide to choose how many candies we count'
                                    : 'Desliza para elegir cuantos caramelos contamos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3F1D6B),
                                ),
                              ),
                              Slider(
                                value: selectedCandies.toDouble(),
                                min: 3,
                                max: 13,
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
                                    isOdd: isOdd,
                                    isLonely: index == lonelyIndex,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isOdd
                                      ? const Color(0x33C2185B)
                                      : const Color(0x3328A745),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isOdd
                                          ? Icons.emoji_emotions
                                          : Icons.check_circle_outline,
                                      color: isOdd
                                          ? const Color(0xFFC2185B)
                                          : const Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        isOdd
                                            ? (isEnglish
                                                ? 'See that lone candy? That makes the group odd!'
                                                : 'Ves ese caramelo solito? Eso hace que el grupo sea impar!')
                                            : (isEnglish
                                                ? 'Every candy paired up. Move the slider to find an odd friend.'
                                                : 'Todos los caramelos tienen pareja. Mueve el control para encontrar un impar.'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isOdd
                                              ? const Color(0xFF880E4F)
                                              : const Color(0xFF1B5E20),
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
                              colors: [Color(0xFFFF6F91), Color(0xFFFF9671)],
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
                              color: Color(0xFF4A235A),
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
                  color: Color(0xFF3F1D6B),
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
        color: const Color(0xFF2C2C54).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332C2C54),
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
                        colors: [Color(0xFFFF758C), Color(0xFF845EC2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40845EC2),
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
    required bool isOdd,
    required bool isLonely,
  }) {
    final Color baseColor =
        isLonely ? const Color(0xFFFF6F91) : const Color(0xFF9575CD);
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
          color: isLonely ? const Color(0xFFC2185B) : Colors.white,
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
    home: OddNumberInfoPage(),
  ));
}
