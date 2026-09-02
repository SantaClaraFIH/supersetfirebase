import 'package:supersetfirebase/gamescreen/mathdecimals/screens/learnpage.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/learnpage2.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/ComparingDecimals.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/FractionsToDecimals.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/reading_decimals_screen.dart';
import 'package:flutter/material.dart';

class LearnSelection extends StatelessWidget {
  const LearnSelection({super.key});

  void _navigateToPage(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero, // Remove default padding
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/MathDecimals/learnsectionbg.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose a Section',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    _buildGameButton(
                        context, 'Introduction', LearnPage(), Colors.green),
                    _buildGameButton(
                        context, 'Place Value', LearnPage2(), Colors.blue),
                    _buildGameButton(context, 'Reading Decimals',
                        ReadingDecimalScreen(), Colors.orange),
                    _buildGameButton(context, 'Comparing Decimals',
                        ComparingDecimalsPage(), Colors.purple),
                    _buildGameButton(context, 'Fraction to Decimal',
                        FractionsToDecimalsScreen(), Colors.teal),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text(
                        'Home',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
      BuildContext context, String title, Widget screen, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _navigateToPage(context, screen),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
