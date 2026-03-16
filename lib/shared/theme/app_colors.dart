import 'package:flutter/material.dart';

class AppColors {
  // --- Ultra-Luxury Dark Palette ---
  static const Color obsidianBlack = Color(0xFF030305);
  static const Color richBlack = obsidianBlack;
  static const Color richSlate = Color(0xFF0D0D12);
  
  // --- Ultra-Luxury Light Palette (Platinum/Pearl) ---
  static const Color pearlWhite = Color(0xFFFBFBFD);
  static const Color softPlatinum = Color(0xFFF2F2F7);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightSlate = Color(0xFFE5E7EB);

  // --- Premium Accents (Shared across modes) ---
  static const Color gold = Color(0xFFD4AF37);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color sapphire = Color(0xFF1E3A8A);
  static const Color emerald = Color(0xFF064E3B);
  static const Color rose = Color(0xFFFB7185);

  // Dynamic Backgrounds Based on context
  static Color getBackground(BuildContext context) {
    return isDarkMode(context) ? obsidianBlack : pearlWhite;
  }

  static Color getCardSurface(BuildContext context) {
    return isDarkMode(context) ? richSlate : pureWhite;
  }

  static Color getTextPrimary(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFFF1F5F9) : const Color(0xFF1D1B20);
  }

  static Color getTextSecondary(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF94A3B8) : const Color(0xFF636366);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Maintaining old static fields for convenience (defaulting to DARK for now if not dynamic)
  static const Color background = obsidianBlack;
  static const Color cardSurface = richSlate;
  static const Color primary = gold;
  static const Color secondary = sapphire;
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  // Still keeping these as neccessary handles for logic
  static const Color green = Color(0xFF10B981);
  static const Color eliteEmerald = Color(0xFF064E3B); 
  static const Color purple = Color(0xFF4C1D95);
  static const Color orange = Color(0xFFB45309);
  static const Color pink = Color(0xFFBE185D);
  static const Color cyan = Color(0xFF0369A1);
  static const Color neonPurple = Color(0xFF581C87);
  static const Color neonPink = Color(0xFF9D174D);
  static const Color digitalVoidPurple = Color(0xFF0A0214);
  static const Color digitalVoidBlack = Color(0xFF030305);
  static const Color cosmicBlue = Color(0xFF010B13);
  static const Color jewelGreen = Color(0xFF065F46); 
  static const Color jewelRed = Color(0xFF7F1D1D); 

  // --- Luxury Gradients (Adapts to brightness) ---
  static LinearGradient getDeepSpaceGradient(BuildContext context) {
    return isDarkMode(context) 
      ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A0F), obsidianBlack])
      : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [pureWhite, softPlatinum]);
  }

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, champagne],
  );

  static const LinearGradient vitreousGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
  );

  static const LinearGradient aiBuilderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D2FF), // Electric Blue
      Color(0xFF9D50BB), // Deep Amethyst
      Color(0xFF6E48AA), // Soft Violet
    ],
  );
}
