import 'package:flutter/material.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'total_xp_display.dart';
import 'total_xp_provider.dart';

class PlayMenu extends StatelessWidget {
  const PlayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TotalXpDisplay(totalXp: totalXp),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/Mathequations/Background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Play Games',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/partsOfEquation');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 24),
                    elevation: 6,
                  ),
                  child: const Text('Parts of an Equation'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/equationToWords');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 24),
                    elevation: 6,
                  ),
                  child: const Text('Equation to words'),
                ),
              ],
            ),
          ),
          // PIN Display
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
          ),
          // Logout Button at Bottom Right
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'equations_logout',
              onPressed: () => logout(context),
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.black,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
