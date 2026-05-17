import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String? recommendedLabel;
  final Color? accentColor;
  final ValueChanged<int> onChanged;

  const CounterRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.recommendedLabel,
    this.accentColor,
    required this.onChanged,
  });

  Color get _accent => accentColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBright),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (recommendedLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    recommendedLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      color: _accent.withAlpha(200),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                enabled: value > min,
                color: _accent,
                onTap: () {
                  if (value > min) {
                    HapticFeedback.lightImpact();
                    onChanged(value - 1);
                  }
                },
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                enabled: value < max,
                color: _accent,
                onTap: () {
                  if (value < max) {
                    HapticFeedback.lightImpact();
                    onChanged(value + 1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(25) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled ? color.withAlpha(80) : Colors.transparent),
        ),
        child: Icon(
          icon,
          color: enabled ? color : Colors.white24,
          size: 18,
        ),
      ),
    );
  }
}
