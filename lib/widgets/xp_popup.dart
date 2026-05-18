import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/sound_service.dart';

class XpPopup {
  static void show(BuildContext context, int amount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XpPopupWidget(
        amount: amount,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    SoundService.instance.play(SoundEvent.win, soundEnabled: true);
  }
}

class _XpPopupWidget extends StatefulWidget {
  final int amount;
  final VoidCallback onDone;
  const _XpPopupWidget({required this.amount, required this.onDone});

  @override
  State<_XpPopupWidget> createState() => _XpPopupWidgetState();
}

class _XpPopupWidgetState extends State<_XpPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.28,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _opacityAnim,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(220),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.gold.withAlpha(100)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(60),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                '+${widget.amount} XP',
                style: GoogleFonts.sora(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withAlpha(128),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
