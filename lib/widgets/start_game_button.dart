import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class StartGameButton extends StatefulWidget {
  final List<String> summaryChips;
  final VoidCallback onStart;
  final Color color;
  final bool enabled;
  final String label;

  const StartGameButton({
    super.key,
    this.summaryChips = const [],
    required this.onStart,
    required this.color,
    this.enabled = true,
    this.label = 'Let\'s Go! 🎮',
  });

  @override
  State<StartGameButton> createState() => _StartGameButtonState();
}

class _StartGameButtonState extends State<StartGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.summaryChips.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.summaryChips
                .map((chip) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.color.withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: widget.color.withAlpha(60)),
                      ),
                      child: Text(
                        chip,
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
        ],
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: widget.enabled ? _pulseAnim.value : 1.0,
            child: child,
          ),
          child: GestureDetector(
            onTap: widget.enabled
                ? () {
                    HapticFeedback.heavyImpact();
                    widget.onStart();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 62,
              decoration: BoxDecoration(
                gradient: widget.enabled
                    ? LinearGradient(
                        colors: [widget.color, widget.color.withAlpha(180)])
                    : null,
                color: widget.enabled ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: widget.color.withAlpha(80),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: widget.enabled ? Colors.white : Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
