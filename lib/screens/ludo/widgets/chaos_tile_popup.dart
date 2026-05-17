import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ChaosTilePopup extends StatefulWidget {
  final String playerName;
  final String prompt;
  final bool isTruth;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const ChaosTilePopup({
    super.key,
    required this.playerName,
    required this.prompt,
    required this.isTruth,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  State<ChaosTilePopup> createState() => _ChaosTilePopupState();
}

class _ChaosTilePopupState extends State<ChaosTilePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (1 - _slideAnim.value) * 300),
        child: child,
      ),
      child: Material(
        color: Colors.black.withAlpha(180),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryContainer.withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withAlpha(60),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rotating swirl
                    RotationTransition(
                      turns: _rotateAnim,
                      child: const Text('🌀', style: TextStyle(fontSize: 44)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'CHAOS TILE',
                      style: GoogleFonts.anybody(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryNeon,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isTruth
                            ? AppColors.truthBlue.withAlpha(30)
                            : AppColors.dareRed.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.isTruth
                              ? AppColors.truthBlue
                              : AppColors.dareRed,
                        ),
                      ),
                      child: Text(
                        widget.isTruth ? 'TRUTH' : 'DARE',
                        style: GoogleFonts.anybody(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 2,
                          color: widget.isTruth
                              ? AppColors.truthBlue
                              : AppColors.dareRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.prompt,
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.playerName,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Done it ✓',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onRefuse,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dareRed,
                          side: BorderSide(color: AppColors.dareRed),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Refuse — back 6 spaces',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
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
