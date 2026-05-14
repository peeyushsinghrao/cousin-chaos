import 'package:flutter/material.dart';

class AppColors {
  // ── Design System Colors from Cousin Chaos Premium UI ──
  
  // Surface Colors
  static const Color surface = Color(0xFF17111F);
  static const Color surfaceDim = Color(0xFF17111F);
  static const Color surfaceBright = Color(0xFF3E3646);
  static const Color surfaceContainerLowest = Color(0xFF110B1A);
  static const Color surfaceContainerLow = Color(0xFF1F1928);
  static const Color surfaceContainer = Color(0xFF231D2C);
  static const Color surfaceContainerHigh = Color(0xFF2E2737);
  static const Color surfaceContainerHighest = Color(0xFF393242);
  static const Color surfaceLight = Color(0xFF2B2436);
  static const Color background = Color(0xFF0A0512);
  
  // On Surface Colors
  static const Color onSurface = Color(0xFFEADEF3);
  static const Color onSurfaceVariant = Color(0xFFCFC2D6);
  static const Color onBackground = Color(0xFFEADEF3);
  
  // Primary (Purple)
  static const Color primary = Color(0xFFDDB7FF);
  static const Color onPrimary = Color(0xFF490080);
  static const Color primaryContainer = Color(0xFFB76DFF);
  static const Color onPrimaryContainer = Color(0xFF400071);
  static const Color primaryFixed = Color(0xFFF0DBFF);
  static const Color primaryFixedDim = Color(0xFFDDB7FF);
  static const Color onPrimaryFixed = Color(0xFF2C0051);
  static const Color onPrimaryFixedVariant = Color(0xFF6900B3);
  static const Color inversePrimary = Color(0xFF842BD2);
  static const Color surfaceTint = Color(0xFFDDB7FF);
  
  // Secondary (Cyan)
  static const Color secondary = Color(0xFF92DBFF);
  static const Color onSecondary = Color(0xFF003547);
  static const Color secondaryContainer = Color(0xFF00C4FD);
  static const Color onSecondaryContainer = Color(0xFF004D66);
  static const Color secondaryFixed = Color(0xFFBFE9FF);
  static const Color secondaryFixedDim = Color(0xFF6DD2FF);
  static const Color onSecondaryFixed = Color(0xFF001F2A);
  static const Color onSecondaryFixedVariant = Color(0xFF004D65);
  static const Color primaryNeon = Color(0xFFE2BEFF);
  static const Color primaryNeonDim = Color(0xFFB88EFF);
  
  // Tertiary (Pink/Red)
  static const Color tertiary = Color(0xFFFFB3B5);
  static const Color onTertiary = Color(0xFF680019);
  static const Color tertiaryContainer = Color(0xFFFF5167);
  static const Color onTertiaryContainer = Color(0xFF5B0015);
  static const Color tertiaryFixed = Color(0xFFFFDADA);
  static const Color tertiaryFixedDim = Color(0xFFFFB3B5);
  static const Color onTertiaryFixed = Color(0xFF40000C);
  static const Color onTertiaryFixedVariant = Color(0xFF920027);
  
  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  
  // Inverse Colors
  static const Color inverseSurface = Color(0xFFEADEF3);
  static const Color inverseOnSurface = Color(0xFF352D3D);
  
  // Outline
  static const Color outline = Color(0xFF988D9F);
  static const Color outlineVariant = Color(0xFF4D4354);
  static const Color surfaceVariant = Color(0xFF393242);
  
  // Legacy Game Accent Colors (for backward compatibility)
  static const Color truthBlue = Color(0xFF00C4FD);
  static const Color truthBlueDark = Color(0xFF003547);
  static const Color dareRed = Color(0xFFFF5167);
  static const Color dareRedDark = Color(0xFF680019);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonYellow = Color(0xFFF5C518);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color neonPink = Color(0xFFFFB3B5);
  static const Color neonCyan = Color(0xFF92DBFF);
  
  // Text Colors (mapped from design system)
  static const Color textPrimary = Color(0xFFEADEF3);
  static const Color textSecondary = Color(0xFFCFC2D6);
  static const Color textMuted = Color(0xFF988D9F);

  // Additional Design System Colors
  static const Color surfaceCard = Color(0x0DFFFFFF);
  static const Color accent = Color(0xFFFF5167);
  static const Color gold = Color(0xFFFFD700);
  static const Color borderGlass = Color(0x26FFFFFF);
  
  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryContainer, primary, secondaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryContainer, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [tertiaryContainer, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient meshGradient = LinearGradient(
    colors: [surfaceDim, Color(0xFF2C0051), Color(0xFF001F2A), surfaceDim],
    begin: Alignment(-0.45, 0),
    end: Alignment(0.45, 1),
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0512), Color(0xFF12082A), Color(0xFF0A0512)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Additional Gradients for Design System
  static const LinearGradient chaosGradient = LinearGradient(
    colors: [tertiaryContainer, tertiary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFF8B0000), Color(0xFFFF0000), Color(0xFFFF5167)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
