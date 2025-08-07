import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

class CrystalColors {
  // AquaSplash gradient for tab bar and main theme
  static const Gradient crystalTabGradient = LinearGradient(
    colors: GradientColors.aquaSplash,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Alternative gradient orientations
  static const Gradient crystalGradientVertical = LinearGradient(
    colors: GradientColors.aquaSplash,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const Gradient crystalGradientHorizontal = LinearGradient(
    colors: GradientColors.aquaSplash,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Primary colors - AquaSplash theme from flutter_gradient_colors
  static const Color primaryBlue = Color(0xFF13547A); // AquaSplash start color
  static const Color primary = Color(0xFF13547A); // Alias for primaryBlue
  static const Color primaryLight = Color(0xFF80D0C7); // AquaSplash end color
  static const Color primaryDark = Color(0xFF0D3B54); // Darker variant
  
  // Stone colors
  static const Color stoneGray = Color(0xFF6B7280);
  static const Color rockBrown = Color(0xFF92400E);
  static const Color crystalWhite = Color(0xFFF9FAFB);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF8FAFC); // Alias for backgroundLight
  static const Color backgroundDark = Color(0xFF0F172A);
  
  // Accent colors
  static const Color gemGreen = Color(0xFF10B981);
  static const Color amberGold = Color(0xFFF59E0B);
  static const Color rubyRed = Color(0xFFEF4444);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color text = Color(0xFF1F2937); // Alias for textPrimary
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
}