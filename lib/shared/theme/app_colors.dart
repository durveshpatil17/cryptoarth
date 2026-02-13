import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF4ADE80); // Vibrant Green from Figma
  static const Color green = Color(0xFF22C55E); // Standard Green
  static const Color background = Color(0xFF0E1117); // Dark Navy/Black
  static const Color cardSurface = Color(0xFF161B22); // Slightly lighter for cards
  
  // Accents
  static const Color cyan = Color(0xFF06B6D4); // AI/Tech Blue
  static const Color gold = Color(0xFFF59E0B); // Premium/Highlights
  static const Color purple = Color(0xFF8B5CF6); // Execution
  static const Color orange = Color(0xFFF97316); // System
  static const Color pink = Color(0xFFEC4899); // Pink accent
  
  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // Grey 400
  
  // Gradients
  static const LinearGradient vignette = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000E1117), // Transparent
      Color(0xFF0E1117), // Solid Background
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4ADE80),
      Color(0xFF22C55E),
    ],
  );
}
