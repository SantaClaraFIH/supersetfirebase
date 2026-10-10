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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MathDecimals/learnsectionbg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 24.0,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Choose a Section',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildGameButton(
                                  context, 'Introduction', const LearnPage(), Colors.green),
                              _buildGameButton(
                                  context, 'Place Value', const LearnPage2(), Colors.blue),
                              _buildGameButton(context, 'Reading Decimals',
                                  const ReadingDecimalScreen(), Colors.orange),
                              _buildGameButton(context, 'Comparing Decimals',
                                  const ComparingDecimalsPage(), Colors.purple),
                              _buildGameButton(context, 'Fraction to Decimal',
                                  const FractionsToDecimalsScreen(), Colors.teal),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  },
                                  child: const Text(
                                    'Home',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
