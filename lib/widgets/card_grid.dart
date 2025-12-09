import 'package:flutter/material.dart';

/// Responsive grid wrapper for game cards
/// Provides consistent spacing and responsive column layout with centered cards
class CardGrid extends StatelessWidget {
  final List<Widget> children;
  final double? maxWidth;
  final EdgeInsets? padding;

  const CardGrid({
    super.key,
    required this.children,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth = maxWidth ?? 1280; // max-w-7xl equivalent

        // Padding and spacing constants
        final horizontalPadding =
            padding?.horizontal ?? 24.0; // px-6 equivalent
        final gap = 32.0; // gap-8 equivalent

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            padding: EdgeInsets.only(
              top: padding?.top ?? 32, // mt-8
              bottom: padding?.bottom ?? 32,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: gap, // gap-8 (horizontal spacing)
              runSpacing: gap, // gap-8 (vertical spacing)
              children: children,
            ),
          ),
        );
      },
    );
  }
}
