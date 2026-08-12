import 'package:flutter/material.dart';
import 'what_are_equations_detail.dart';
import 'importance_of_equations.dart';
import 'real_world_applications.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'total_xp_display.dart';
import 'total_xp_provider.dart';

class WhatAreEquations extends StatelessWidget {
  const WhatAreEquations({super.key});

  @override
  Widget build(BuildContext context) {
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;
    final totalXp = Provider.of<TotalXpProvider>(context).bestScore;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            heroTag: 'equations_back',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF4A4A4A),
              size: 26,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TotalXpDisplay(totalXp: totalXp),
          ),
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
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const WhatAreEquationsDetail())),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 24),
                    elevation: 6,
                  ),
                  child: const Text('What Are Equations?'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ImportanceOfEquations())),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 24),
                    elevation: 6,
                  ),
                  child: const Text('Importance of Equations in Mathematics'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RealWorldApplications())),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 24),
                    elevation: 6,
                  ),
                  child: const Text('Real-world Applications of Equations'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          // PIN Display (Center)
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
          // Logout Button (Right)
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
