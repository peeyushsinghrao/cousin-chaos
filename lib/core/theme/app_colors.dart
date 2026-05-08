import 'package:flutter/material.dart';

class AppColors {
  // ── Midnight Neon Background System ──
  static const Color background = Color(0xFF0A0512);
  static const Color surface = Color(0xFF150D22);
  static const Color surfaceLight = Color(0xFF1E1433);
  static const Color surfaceBright = Color(0xFF2A1C45);

  // ── Primary Neon Palette ──
  static const Color primaryNeon = Color(0xFFB026FF);
  static const Color primaryNeonDim = Color(0xFF7B1FA2);

  // ── Game Accent Colors ──
  static const Color truthBlue = Color(0xFF00C6FF);
  static const Color truthBlueDark = Color(0xFF0072FF);
  static const Color dareRed = Color(0xFFFF2D55);
  static const Color dareRedDark = Color(0xFFD50032);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonYellow = Color(0xFFF5C518);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonCyan = Color(0xFF00F5FF);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A3C0);
  static const Color textMuted = Color(0xFF6B5E80);

  // ── Gradients ──
  static const LinearGradient truthGradient = LinearGradient(
    colors: [truthBlue, truthBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dareGradient = LinearGradient(
    colors: [dareRed, dareRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, primaryNeonDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0512), Color(0xFF12082A), Color(0xFF0A0512)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
