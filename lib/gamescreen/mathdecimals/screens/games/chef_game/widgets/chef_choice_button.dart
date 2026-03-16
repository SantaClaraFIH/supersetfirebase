import 'dart:math';

import 'package:flutter/material.dart';

class ChefChoiceButton extends StatelessWidget {
  const ChefChoiceButton({
    super.key,
    required this.label,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    this.wrongBorderValue = 0.0,
    required this.onTap,
  });

  final String label;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;
  final double wrongBorderValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIdle = !isCorrect && !isWrong && !isDisabled;

    final List<Color>? gradientColors;
    final Color? backgroundColor;
    final Border? border;
    final IconData? icon;
    final Color textColor;
    final Color? iconColor;
    final List<BoxShadow> boxShadows;

    if (isCorrect) {
      gradientColors = [Colors.green.shade400, Colors.green.shade700];
      backgroundColor = null;
      border = null;
      icon = Icons.check_circle;
      textColor = Colors.white;
      iconColor = Colors.white;
      boxShadows = [
        const BoxShadow(color: Colors.white24, blurRadius: 2, offset: Offset(0, -1)),
        BoxShadow(color: Colors.green.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 1),
      ];
    } else if (isWrong) {
      final borderWidth = 2.0 + 3.0 * (0.5 + 0.5 * sin(pi * wrongBorderValue));
      gradientColors = [Colors.red.shade400, Colors.red.shade700];
      backgroundColor = null;
      border = Border.all(color: Colors.red.shade700, width: borderWidth);
      icon = Icons.cancel;
      textColor = Colors.white;
      iconColor = Colors.white;
      boxShadows = [
        const BoxShadow(color: Colors.white24, blurRadius: 2, offset: Offset(0, -1)),
      ];
    } else if (isDisabled) {
      gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
      backgroundColor = null;
      border = null;
      icon = null;
      textColor = Colors.white;
      iconColor = null;
      boxShadows = [
        const BoxShadow(color: Colors.white24, blurRadius: 2, offset: Offset(0, -1)),
      ];
    } else {
      gradientColors = null;
      backgroundColor = Colors.amber.shade50;
      border = Border.all(color: Colors.orange.shade400, width: 3);
      icon = Icons.restaurant_menu;
      textColor = Colors.brown.shade800;
      iconColor = Colors.orange.shade700;
      boxShadows = [
        BoxShadow(
          color: Colors.orange.shade200.withValues(alpha: 0.6),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
        const BoxShadow(color: Colors.white, blurRadius: 2, offset: Offset(0, -1)),
      ];
    }

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        elevation: isIdle ? 2 : 4,
        shadowColor: (isCorrect ? Colors.green : isWrong ? Colors.red : Colors.orange)
            .withValues(alpha: 0.35),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: backgroundColor,
              border: border,
              boxShadow: boxShadows,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor ?? Colors.white, size: 22),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (icon != null && (isCorrect || isWrong)) const SizedBox(width: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

