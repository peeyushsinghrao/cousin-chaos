import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isInteractive;
  final List<BoxShadow>? boxShadow;
  final Gradient? borderGradient;
  final double? blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.isInteractive = false,
    this.boxShadow,
    this.borderGradient,
    this.blur,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 16.0;
    final effectiveBlur = blur ?? 20.0;

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainer.withOpacity(0.05),
            AppColors.surfaceContainer.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              gradient: borderGradient ?? AppColors.glassBorderGradient,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

    if (isInteractive && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? height;
  final double? borderRadius;
  final bool isPrimary;
  final List<BoxShadow>? boxShadow;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.gradient,
    this.height,
    this.borderRadius,
    this.isPrimary = true,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 24.0;
    final effectiveHeight = height ?? 56.0;

    if (isPrimary) {
      return Container(
        height: effectiveHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          gradient: gradient ?? AppColors.primaryGradient,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
          ),
          child: child,
        ),
      );
    }

    return GlassCard(
      borderRadius: effectiveBorderRadius,
      onTap: onPressed,
      isInteractive: true,
      child: SizedBox(
        height: effectiveHeight,
        child: Center(child: child),
      ),
    );
  }
}
