import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'app_colors.dart';

class AppTheme {
  // ── Design System Typography ──
  // Display: Anybody (variable, high-impact)
  // Headings: Sora (geometric, modern)
  // Body: Plus Jakarta Sans (friendly, legible)

  // ── Helper Methods ──

  /// Glass decoration with white 5% fill, white 15% border, 16px radius
  static BoxDecoration glassDecoration({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.borderGlass,
        width: 1,
      ),
    );
  }

  /// Neon glow effect for boxes
  static List<BoxShadow> neonGlow(Color color, {double blurRadius = 20, double spreadRadius = 0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.5),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: blurRadius * 2,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Primary gradient - purple to cyan
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Chaos gradient - pink to purple
  static const LinearGradient chaosGradient = AppColors.chaosGradient;

  /// Danger gradient - dark red to pink
  static const LinearGradient dangerGradient = AppColors.dangerGradient;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: AppColors.onError,
      ),
      textTheme: TextTheme(
        // Display XL - Anybody, 64px, weight 800
        displayLarge: GoogleFonts.anybody(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 64,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        // Display LG - Anybody, 48px, weight 800
        displayMedium: GoogleFonts.anybody(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 48,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        // Headline LG - Sora, 32px, weight 700
        headlineLarge: GoogleFonts.sora(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          height: 1.2,
        ),
        // Headline LG Mobile - Sora, 28px, weight 700
        headlineMedium: GoogleFonts.sora(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          height: 1.2,
        ),
        // Title Large - Sora, 20px, weight 600
        titleLarge: GoogleFonts.sora(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        // Title Medium - Sora, 16px, weight 600
        titleMedium: GoogleFonts.sora(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        // Body LG - Plus Jakarta Sans, 18px, weight 500
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.6,
        ),
        // Body MD - Plus Jakarta Sans, 16px, weight 400
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.6,
        ),
        // Body Small - Plus Jakarta Sans, 14px, weight 400
        bodySmall: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.5,
        ),
        // Label MD - Sora, 14px, weight 600, letter spacing 0.05em
        labelLarge: GoogleFonts.sora(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.4,
          letterSpacing: 0.05,
        ),
        // Label Small - Sora, 12px, weight 600
        labelSmall: GoogleFonts.sora(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.4,
          letterSpacing: 0.05,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.sora(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryFixed,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.sora(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.05,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      useMaterial3: true,
    );
  }
}
