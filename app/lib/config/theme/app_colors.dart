import 'package:flutter/material.dart';

/// Centralized color palette for the application.
///
/// Do not use `Colors.*` directly in widgets.
/// Always add reusable colors here first.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF14B8A6);

  // Feedback
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
}