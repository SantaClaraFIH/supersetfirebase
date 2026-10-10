import 'package:flutter/material.dart';

class RecipeSelectionCard extends StatelessWidget {
  const RecipeSelectionCard({
    super.key,
    required this.name,
    required this.description,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    this.scale = 1.0,
  });

  final String name;
  final String description;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale.clamp(0.65, 1.0);
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(24 * s),
        elevation: 4,
        shadowColor: Colors.orange.withValues(alpha: 0.4),
        child: GestureDetector(
          onTap: onTap,
          onTapDown: (_) => onTapDown(),
          onTapUp: (_) => onTapUp(),
          onTapCancel: onTapCancel,
          child: Container(
            constraints: BoxConstraints(minHeight: (56 * s).clamp(44.0, 56.0)),
            padding: EdgeInsets.symmetric(
              vertical: (20 * s).clamp(12.0, 20.0),
              horizontal: (20 * s).clamp(12.0, 20.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24 * s),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF9800),
                  Color(0xFFE65100),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withValues(alpha: 0.3),
                  blurRadius: 8 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: (32 * s).clamp(20.0, 32.0),
                ),
                SizedBox(width: (16 * s).clamp(10.0, 16.0)),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: (24 * s).clamp(16.0, 24.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: (8 * s).clamp(4.0, 8.0)),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: (16 * s).clamp(12.0, 16.0),
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

