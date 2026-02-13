import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFF48C25);
  static const Color primaryDark = Color(0xFFD3761B);
  static const Color primaryLight = Color(0xFFFFB36B);

  // Secondary colors
  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryLight = Color(0xFF334155);

  // Background colors
  static const Color background = Color(0xFFF8F7F5);
  static const Color surface = Colors.white;

  // Status colors
  static const Color pending = Color(0xFFFFB800);
  static const Color inProgress = Color(0xFF4B91F7);
  static const Color delivered = Color(0xFF00D084);
  static const Color error = Color(0xFFEF4444);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  // Border and Shadow
  static const Color border = Color(0xFFE2E8F0);
  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
