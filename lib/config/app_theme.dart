import 'package:flutter/material.dart';

abstract class AppColorScheme {
  List<Color> get backgroundGradient;
  Color get cardBackground;
  Color get cardBorder;
  Color get cardShadow;
  List<Color> get floatingElements;
  Color get primaryText;
  Color get secondaryText;
  Color get accentText;
  Color get primaryButton;
  Color get primaryButtonShadow;
  Color get secondaryButton;
  Color get inputBackground;
  Color get inputBorder;
  Color get inputFocusBorder;
  Color get gridColor;
  Color get geometricShape1;
  Color get geometricShape2;
}

class AppColors {
  // Colorful Light Mode Colors
  static const ColorfulLightColors _light = ColorfulLightColors();
  static const ColorfulDarkColors _dark = ColorfulDarkColors();

  static const ColorfulLightColors light = _light;
  static const ColorfulDarkColors dark = _dark;
}

class ColorfulLightColors implements AppColorScheme {
  const ColorfulLightColors();

  // Background gradients - soft pastels
  List<Color> get backgroundGradient => [
        const Color(0xFFE3F2FD), // Light blue
        const Color(0xFFE8F5E8), // Mint green
        const Color(0xFFFFF8E1), // Soft yellow
      ];

  // Card colors - white with subtle tints
  Color get cardBackground => const Color(0xFFFAFAFA).withOpacity(0.95);
  Color get cardBorder => const Color(0xFFE1F5FE).withOpacity(0.3);
  Color get cardShadow => const Color(0xFFB3E5FC).withOpacity(0.2);

  // Floating math elements - bright pastels
  List<Color> get floatingElements => [
        const Color(0xFFFF6B9D), // Soft pink
        const Color(0xFF6BCF7F), // Mint green
        const Color(0xFF4D96FF), // Soft blue
        const Color(0xFFFFD93D), // Warm yellow
        const Color(0xFFFF8A65), // Coral
        const Color(0xFF9C88FF), // Lavender
        const Color(0xFFFFB74D), // Peach
        const Color(0xFF4DD0E1), // Sky blue
      ];

  // Text colors - dark but not black
  Color get primaryText => const Color(0xFF1E293B); // Dark gray
  Color get secondaryText => const Color(0xFF475569); // Medium gray
  Color get accentText => const Color(0xFF6C63FF); // Purple accent

  // Button colors - maintain purple core
  Color get primaryButton => const Color(0xFF6C63FF);
  Color get primaryButtonShadow => const Color(0xFF6C63FF).withOpacity(0.4);
  Color get secondaryButton => const Color(0xFFF1F5F9);

  // Input field colors
  Color get inputBackground => const Color(0xFFF8FAFC);
  Color get inputBorder => const Color(0xFFE2E8F0);
  Color get inputFocusBorder => const Color(0xFF6C63FF);

  // Grid pattern
  Color get gridColor => const Color(0xFFE2E8F0).withOpacity(0.3);

  // Geometric shapes
  Color get geometricShape1 => const Color(0xFF6C63FF).withOpacity(0.05);
  Color get geometricShape2 => const Color(0xFFFF6B9D).withOpacity(0.05);
}

class ColorfulDarkColors implements AppColorScheme {
  const ColorfulDarkColors();

  // Background gradients - dark but colorful
  List<Color> get backgroundGradient => [
        const Color(0xFF1A1A2E), // Navy
        const Color(0xFF16213E), // Deep purple
        const Color(0xFF0F3460), // Muted teal
      ];

  // Card colors - dark charcoal with subtle gradient
  Color get cardBackground => const Color(0xFF2D3748).withOpacity(0.95);
  Color get cardBorder => const Color(0xFF4A5568).withOpacity(0.3);
  Color get cardShadow => const Color(0xFF1A202C).withOpacity(0.4);

  // Floating math elements - glowing pastel tones
  List<Color> get floatingElements => [
        const Color(0xFFFF6B9D).withOpacity(0.8), // Glowing pink
        const Color(0xFF6BCF7F).withOpacity(0.8), // Glowing mint
        const Color(0xFF4D96FF).withOpacity(0.8), // Glowing blue
        const Color(0xFFFFD93D).withOpacity(0.8), // Glowing yellow
        const Color(0xFFFF8A65).withOpacity(0.8), // Glowing coral
        const Color(0xFF9C88FF).withOpacity(0.8), // Glowing lavender
        const Color(0xFFFFB74D).withOpacity(0.8), // Glowing peach
        const Color(0xFF4DD0E1).withOpacity(0.8), // Glowing sky blue
      ];

  // Text colors - soft white and light gray
  Color get primaryText => const Color(0xFFF7FAFC); // Soft white
  Color get secondaryText => const Color(0xFFE2E8F0); // Light gray
  Color get accentText => const Color(0xFF9F7AEA); // Light purple

  // Button colors - glowing or high-contrast accents
  Color get primaryButton => const Color(0xFF6C63FF);
  Color get primaryButtonShadow => const Color(0xFF6C63FF).withOpacity(0.6);
  Color get secondaryButton => const Color(0xFF4A5568);

  // Input field colors
  Color get inputBackground => const Color(0xFF2D3748);
  Color get inputBorder => const Color(0xFF4A5568);
  Color get inputFocusBorder => const Color(0xFF9F7AEA);

  // Grid pattern
  Color get gridColor => const Color(0xFF4A5568).withOpacity(0.2);

  // Geometric shapes
  Color get geometricShape1 => const Color(0xFF6C63FF).withOpacity(0.1);
  Color get geometricShape2 => const Color(0xFFFF6B9D).withOpacity(0.1);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.primaryButton,
        brightness: Brightness.light,
        primary: AppColors.light.primaryButton,
        secondary: AppColors.light.accentText,
        surface: AppColors.light.cardBackground,
        background: AppColors.light.backgroundGradient.first,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.light.primaryText,
        onBackground: AppColors.light.primaryText,
      ),
      scaffoldBackgroundColor: AppColors.light.backgroundGradient.first,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.light.primaryText,
        titleTextStyle: TextStyle(
          color: AppColors.light.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.cardBackground,
        elevation: 8,
        shadowColor: AppColors.light.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.light.primaryButton,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.light.primaryButtonShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.light.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.light.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.light.inputFocusBorder, width: 2),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.light.primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.light.primaryText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.light.primaryText,
        ),
        bodyMedium: TextStyle(
          color: AppColors.light.secondaryText,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.primaryButton,
        brightness: Brightness.dark,
        primary: AppColors.dark.primaryButton,
        secondary: AppColors.dark.accentText,
        surface: AppColors.dark.cardBackground,
        background: AppColors.dark.backgroundGradient.first,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.dark.primaryText,
        onBackground: AppColors.dark.primaryText,
      ),
      scaffoldBackgroundColor: AppColors.dark.backgroundGradient.first,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.dark.primaryText,
        titleTextStyle: TextStyle(
          color: AppColors.dark.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.cardBackground,
        elevation: 8,
        shadowColor: AppColors.dark.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark.primaryButton,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.dark.primaryButtonShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dark.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dark.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.dark.inputFocusBorder, width: 2),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.dark.primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.dark.primaryText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.dark.primaryText,
        ),
        bodyMedium: TextStyle(
          color: AppColors.dark.secondaryText,
        ),
      ),
    );
  }
}
