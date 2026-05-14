import 'package:flutter/material.dart';

/// Reusable animation utilities for Impostor Mode
class ImpostorAnimations {
  // Glow animation
  static Widget createGlowAnimation({
    required Widget child,
    required Color glowColor,
    double glowRadius = 20,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: glowRadius,
            spreadRadius: -5,
          ),
        ],
      ),
      child: child,
    );
  }

  // Pulse animation
  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // Fade and scale animation
  static Animation<double> createFadeScaleAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }

  // Slide animation
  static Animation<Offset> createSlideAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }

  // Shimmer effect
  static Shader createShimmerShader(
    Rect bounds,
    Color baseColor,
    Color highlightColor,
  ) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.1, 0.5, 0.9],
    ).createShader(bounds);
  }
}

/// Gradient utilities
class ImpostorGradients {
  static LinearGradient get cinemaRedGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF0000).withOpacity(0.8),
        const Color(0xFF8B0000).withOpacity(0.6),
      ],
    );
  }

  static LinearGradient get successGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF00D084).withOpacity(0.8),
        const Color(0xFF00A366).withOpacity(0.6),
      ],
    );
  }

  static LinearGradient get neonGlass {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
    );
  }
}
