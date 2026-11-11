import 'package:flutter/material.dart';

import '../widgets/top_bar.dart';
import 'fractions_game_view.dart';

class FractionsWebViewScreen extends StatelessWidget {
  const FractionsWebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 140,
            child: TopBar(
              title: 'Fractions',
              showBackButton: true,
              showLogout: false,
            ),
          ),
          Expanded(child: FractionsGameView()),
        ],
      ),
    );
  }
}
