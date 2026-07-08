import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'LearnAI';
  static const String appVersion = '1.0.0';

  // Gemini API - Replace with your API key
  static const String geminiApiKey = 'AIzaSyBLAwYcYbz3rnJD0krl3erQD9i76j4zWKA';

  // Hive Box Names
  static const String userBox = 'userBox';
  static const String progressBox = 'progressBox';
  static const String lessonBox = 'lessonBox';
  static const String quizBox = 'quizBox';

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Categories
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Programming', 'icon': Icons.code, 'color': Color(0xFF6366F1)},
    {
      'name': 'Mathematics',
      'icon': Icons.calculate,
      'color': Color(0xFFEC4899),
    },
    {'name': 'Science', 'icon': Icons.science, 'color': Color(0xFF10B981)},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Color(0xFFF59E0B)},
    {'name': 'Languages', 'icon': Icons.language, 'color': Color(0xFF8B5CF6)},
    {'name': 'Business', 'icon': Icons.business, 'color': Color(0xFF06B6D4)},
  ];
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFFEC4899);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  static LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
