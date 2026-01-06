import 'package:flutter/material.dart';

/// Iron & Rust Theme - Gritty Powerlifting/CrossFit Theme
class AppColors {
  // ===========================================
  // IRON & RUST THEME - Gritty, Raw, Industrial
  // ===========================================
  
  // Primary - Safety Orange (Call to Action)
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primaryLight = Color(0xFFFF8A65);
  
  // Secondary - Concrete (Inactive elements)
  static const Color secondary = Color(0xFF37474F);
  static const Color secondaryDark = Color(0xFF263238);
  static const Color secondaryLight = Color(0xFF546E7A);
  
  // Background - Charcoal
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF263238); // Dark Slate Surface
  static const Color surface = Color(0xFF263238);
  static const Color surfaceLight = Color(0xFF37474F);
  static const Color darkBackground = Color(0xFF0D0D0D);
  
  // Text
  static const Color textPrimary = Color(0xFFECEFF1); // Mist - High readability
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textLight = Color(0xFF78909C);
  static const Color textDark = Color(0xFFECEFF1);
  static const Color textMuted = Color(0xFF607D8B);
  
  // Accent - Caution Yellow (PRs, Warnings)
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFD54F);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF29B6F6);
  
  // Gym Status Colors (Gritty version)
  static const Color gymEmpty = Color(0xFF4CAF50);
  static const Color gymModerate = Color(0xFFFFC107);
  static const Color gymBusy = Color(0xFFFF9800);
  static const Color gymPacked = Color(0xFFFF5722);
  
  // Macros - Vibrant against dark
  static const Color protein = Color(0xFFFF5722);
  static const Color carbs = Color(0xFF4CAF50);
  static const Color fats = Color(0xFFFFC107);
  static const Color calories = Color(0xFFE91E63);
  
  // Water
  static const Color water = Color(0xFF03A9F4);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF263238)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF263238), Color(0xFF1E272C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFE64A19), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
