import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'hover_effects.dart';

/// Reusable game card widget matching main page card design
/// Uses BoxFit.contain to prevent image cropping and maintains fixed aspect ratio
class GameCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageSrc;
  final VoidCallback? onClick;
  final AppColorScheme colors;
  final bool isDarkMode;

  const GameCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageSrc,
    this.onClick,
    required this.colors,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onClick,
      hoverScale: 1.05,
      hoverElevation: 20.0,
      hoverGlowColor: colors.floatingElements[2],
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 288, // 18rem * 16 = 288px
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.cardBackground.withOpacity(0.85),
              colors.cardBackground.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24), // rounded-3xl
          border: Border.all(
            color: colors.floatingElements[2].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with fixed aspect ratio (1:1)
            // Padding around image
            Padding(
              padding: const EdgeInsets.all(16.0), // mx-4 mt-4
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), // rounded-2xl
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                ),
                child: AspectRatio(
                  aspectRatio: 1.0, // 1:1 aspect ratio
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imageSrc,
                      fit: BoxFit.contain, // Never crop - use contain
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colors.cardBackground.withOpacity(0.3),
                          child: Icon(
                            Icons.image_not_supported,
                            color: colors.secondaryText,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Title and subtitle section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), // px-4 pb-5
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18, // text-lg
                      fontWeight: FontWeight.w600, // font-semibold
                      color: colors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14, // text-sm
                        color: colors.secondaryText.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
