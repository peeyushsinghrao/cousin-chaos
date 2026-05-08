import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const GradientIconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(50),
            color.withAlpha(10),
          ],
        ),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: size * 0.4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: size * 0.55,
        ),
      ),
    );
  }
}
