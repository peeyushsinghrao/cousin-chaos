import 'dart:math';
import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/sound_service.dart';

class PhysicsWheel extends StatefulWidget {
  final List<String> items;
  final void Function(int selectedIndex) onSpinComplete;
  final List<Color>? sliceColors;
  final double size;

  const PhysicsWheel({
    super.key,
    required this.items,
    required this.onSpinComplete,
    this.sliceColors,
    this.size = 300,
  });

  @override
  State<PhysicsWheel> createState() => PhysicsWheelState();
}

class PhysicsWheelState extends State<PhysicsWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  int _lastTickSlice = -1;
  bool _isSpinning = false;
  final _random = Random();

  final List<Color> _defaultColors = [
    AppColors.primaryNeon,
    AppColors.truthBlue,
    AppColors.dareRed,
    AppColors.neonGreen,
    AppColors.neonYellow,
    AppColors.neonOrange,
    AppColors.neonPink,
    AppColors.neonCyan,
    AppColors.primaryNeonDim,
    const Color(0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_onTick);
  }

  void _onTick() {
    setState(() {
      _angle = _controller.value;
    });
    final sliceAngle = 2 * pi / widget.items.length;
    final currentSlice = (_angle / sliceAngle).floor();
    if (currentSlice != _lastTickSlice) {
      _lastTickSlice = currentSlice;
      HapticFeedback.selectionClick();
    }
  }

  void _calculateWinner() {
    if (widget.items.isEmpty) return;
    double normalizedAngle = _angle % (2 * pi);
    if (normalizedAngle < 0) normalizedAngle += 2 * pi;
    final sliceAngle = 2 * pi / widget.items.length;
    final adjustedAngle =
        (2 * pi - normalizedAngle + sliceAngle / 2) % (2 * pi);
    final winnerIndex = (adjustedAngle / sliceAngle).floor() % widget.items.length;
    HapticFeedback.heavyImpact();
    SoundService.instance.play(SoundEvent.wheelLand, soundEnabled: true);
    widget.onSpinComplete(winnerIndex);
  }

  void triggerSpin() {
    if (_isSpinning) return;
    final extraSpins = 5 + _random.nextInt(3);
    final offset = _random.nextDouble() * 2 * pi;
    final targetAngle = _angle + extraSpins * 2 * pi + offset;
    setState(() => _isSpinning = true);
    SoundService.instance.play(SoundEvent.wheelSpin, soundEnabled: true);
    _controller
        .animateTo(
          targetAngle,
          duration: const Duration(milliseconds: 3500),
          curve: Curves.decelerate,
        )
        .then((_) {
      if (mounted) {
        setState(() => _isSpinning = false);
        _calculateWinner();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final wheelSize = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: wheelSize + 40,
          height: wheelSize + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: wheelSize + 30,
                height: wheelSize + 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNeon.withAlpha(40),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: _angle,
                child: CustomPaint(
                  size: Size(wheelSize, wheelSize),
                  painter: _WheelPainter(
                    items: widget.items,
                    colors: widget.sliceColors ?? _defaultColors,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(
                      color: AppColors.surfaceBright, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.touch_app_rounded,
                      color: AppColors.textMuted, size: 18),
                ),
              ),
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: const Size(32, 28),
                  painter: _PointerPainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _isSpinning ? null : triggerSpin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              gradient: _isSpinning
                  ? LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade800])
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(50),
              boxShadow: _isSpinning
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(100),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSpinning ? LucideIcons.loader : LucideIcons.zap,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _isSpinning ? 'SPINNING...' : 'SPIN',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;

  _WheelPainter({required this.items, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = 2 * pi / items.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    for (int i = 0; i < items.length; i++) {
      paint.color = colors[i % colors.length];
      final startAngle = i * sliceAngle - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        startAngle,
        sliceAngle,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sliceAngle / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: items.length > 6 ? 11 : 14,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: Colors.black.withAlpha(180),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      textPainter.layout(maxWidth: radius * 0.55);
      textPainter.paint(
        canvas,
        Offset(radius * 0.28, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.items != items;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
