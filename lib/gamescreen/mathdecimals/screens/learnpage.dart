import 'package:flutter/material.dart';
import 'learnpage2.dart';
import 'package:supersetfirebase/services/translation_service.dart';

// This is the introduction page
class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final Map<String, String> originalTexts = {
    'heading': 'What are Decimals?',
    'body':
        'Decimals are a way of expressing numbers that are not whole numbers. They are numbers with a dot, called a decimal point.',
    'example': 'Decimal Example: 0.1 means one-tenth.',
    'NextPage': 'Next Page'
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
        translated = false; // Mark as untranslated
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduction'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearnPage2()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading
            Center(
              child: Text(
                translated
                    ? translatedTexts['heading'] ?? originalTexts['heading']!
                    : originalTexts['heading']!,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 50),

            // Description Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light background for better contrast
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                translated
                    ? translatedTexts['body'] ?? originalTexts['body']!
                    : originalTexts['body']!,
                style: const TextStyle(fontSize: 18, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 20),

            // Example Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Slightly different background
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                translated
                    ? translatedTexts['example'] ?? originalTexts['example']!
                    : originalTexts['example']!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 60),

            // Image Centered
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/MathDecimals/decimal1.png',
                  width: 320,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Next Page Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LearnPage2()),
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
            ),
          ],
        ),
      ),
    );
  }
}
