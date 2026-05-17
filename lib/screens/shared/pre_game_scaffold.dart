import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PreGameScaffold extends StatelessWidget {
  final String modeName;
  final Color modeColor;
  final int step;
  final int totalSteps;
  final Widget body;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool ctaEnabled;

  const PreGameScaffold({
    super.key,
    required this.modeName,
    required this.modeColor,
    required this.step,
    required this.totalSteps,
    required this.body,
    required this.ctaLabel,
    this.onCta,
    this.ctaEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF08041A),
              modeColor.withAlpha(18),
              const Color(0xFF08041A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildStepIndicator(),
              Expanded(child: body),
              _buildCta(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(18)),
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            modeName.toUpperCase(),
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: modeColor,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (i) {
          final active = i + 1 == step;
          final done = i + 1 < step;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: done || active ? modeColor : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: GestureDetector(
        onTap: ctaEnabled ? onCta : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: ctaEnabled
                ? LinearGradient(
                    colors: [modeColor, modeColor.withAlpha(180)])
                : null,
            color: ctaEnabled ? null : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: ctaEnabled
                ? [
                    BoxShadow(
                      color: modeColor.withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              ctaLabel,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ctaEnabled ? Colors.white : Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
