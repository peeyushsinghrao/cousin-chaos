import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/chaos_event_service.dart';

class ChaosEventOverlay extends StatefulWidget {
  final ChaosEvent event;
  final VoidCallback onDismiss;

  const ChaosEventOverlay({super.key, required this.event, required this.onDismiss});

  static void show(BuildContext context, ChaosEvent event, VoidCallback onDismiss) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(160),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) => ChaosEventOverlay(event: event, onDismiss: onDismiss),
    );
  }

  @override
  State<ChaosEventOverlay> createState() => _ChaosEventOverlayState();
}

class _ChaosEventOverlayState extends State<ChaosEventOverlay> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact());

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
    _shakeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.event.type) {
      case ChaosEventType.everyone: return AppColors.neonGreen;
      case ChaosEventType.swap: return AppColors.secondary;
      case ChaosEventType.double: return AppColors.dareRed;
      case ChaosEventType.reverse: return AppColors.neonOrange;
      case ChaosEventType.wildcard: return AppColors.primary;
      case ChaosEventType.skip: return AppColors.neonYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _accentColor.withAlpha(150), width: 2),
                boxShadow: [
                  BoxShadow(color: _accentColor.withAlpha(80), blurRadius: 40, spreadRadius: 10),
                  BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 + _pulseController.value * 0.1,
                      child: child,
                    ),
                    child: Text(widget.event.emoji, style: const TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentColor.withAlpha(80)),
                    ),
                    child: Text(
                      'CHAOS EVENT',
                      style: GoogleFonts.sora(color: _accentColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anybody(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(color: Colors.white70, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      widget.onDismiss();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_accentColor, _accentColor.withAlpha(180)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: _accentColor.withAlpha(80), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text('GOT IT!', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
