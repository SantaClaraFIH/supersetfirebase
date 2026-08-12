import 'package:supersetfirebase/gamescreen/mathdecimals/screens/FractionsToDecimals.dart';
import 'package:flutter/material.dart';
import 'package:supersetfirebase/services/translation_service.dart';

class ComparingDecimalsPage extends StatefulWidget {
  const ComparingDecimalsPage({super.key});

  @override
  State<ComparingDecimalsPage> createState() => _ComparingDecimalsPageState();
}

class _ComparingDecimalsPageState extends State<ComparingDecimalsPage> {
  final Map<String, String> originalTexts = {
    'title': 'Comparing Decimals',
    'body': '👉 Example: Which is bigger: 3.45 or 3.5?\n'
        '- Whole numbers: 3 and 3 → same!\n'
        '- Tenths: 4 vs 5 → 5 is bigger!\n'
        'So, 3.45 is smaller than 3.5\n\n'
        '📌 Tip: You can write 3.5 as 3.50 to compare easily.\n'
        'Now compare: 3.45 < 3.50',
    'NextPage': 'Next Page', // ✅ Added this key
  };

  Map<String, String> translatedTexts = {};
  bool translated = false;

  Future<void> translateTexts() async {
    if (!translated) {
      try {
        final translations = await TranslationService.translateMap(originalTexts);
        setState(() {
          translatedTexts = translations;
          translated = true;
        });
      } catch (e) {
        debugPrint('Failed to fetch translations: $e');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Comparing Decimals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(context),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              translated
                  ? translatedTexts['title'] ?? originalTexts['title']!
                  : originalTexts['title']!,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                translated
                    ? translatedTexts['body'] ?? originalTexts['body']!
                    : originalTexts['body']!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/MathDecimals/comparingdecimals.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            // ✅ Added Next Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FractionsToDecimalsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    translated
                        ? translatedTexts['NextPage'] ??
                            originalTexts['NextPage']!
                        : originalTexts['NextPage']!,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
