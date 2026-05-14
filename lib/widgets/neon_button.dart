import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final IconData? icon;
  final double? height;
  final double? width;
  final bool isEnabled;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.icon,
    this.height,
    this.width,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppTheme.primaryGradient;

    return Container(
      height: height ?? 56,
      width: width,
      decoration: BoxDecoration(
        gradient: isEnabled ? effectiveGradient : null,
        color: isEnabled ? null : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isEnabled ? AppTheme.neonGlow(effectiveGradient.colors.first) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isEnabled ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
