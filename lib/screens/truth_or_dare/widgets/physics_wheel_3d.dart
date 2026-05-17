import 'dart:math';
import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/sound_service.dart';

class PhysicsWheel3D extends StatefulWidget {
  final List<String> items;
  final void Function(int selectedIndex) onSpinComplete;
  final List<Color>? sliceColors;
  final double size;

  const PhysicsWheel3D({
    super.key,
    required this.items,
    required this.onSpinComplete,
    this.sliceColors,
    this.size = 300,
  });

  @override
  State<PhysicsWheel3D> createState() => PhysicsWheel3DState();
}

class PhysicsWheel3DState extends State<PhysicsWheel3D> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;
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
    _spinController = AnimationController.unbounded(vsync: this);
    _spinController.addListener(_onTick);

    _tiltController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _tiltAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
    );
  }

  void _onTick() {
    setState(() => _angle = _spinController.value);
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
    final adjustedAngle = (2 * pi - normalizedAngle + sliceAngle / 2) % (2 * pi);
    final winnerIndex = (adjustedAngle / sliceAngle).floor() % widget.items.length;
    HapticFeedback.heavyImpact();
    SoundService.instance.play(SoundEvent.wheelLand, soundEnabled: true);
    _tiltController.reverse();
    widget.onSpinComplete(winnerIndex);
  }

  void triggerSpin() {
    if (_isSpinning) return;
    final extraSpins = 5 + _random.nextInt(3);
    final offset = _random.nextDouble() * 2 * pi;
    final targetAngle = _angle + extraSpins * 2 * pi + offset;
    setState(() => _isSpinning = true);
    _tiltController.forward();
    SoundService.instance.play(SoundEvent.wheelSpin, soundEnabled: true);
    _spinController
        .animateTo(targetAngle, duration: const Duration(milliseconds: 3500), curve: Curves.decelerate)
        .then((_) {
      if (mounted) {
        setState(() => _isSpinning = false);
        _calculateWinner();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final wheelSize = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _tiltAnimation,
          builder: (_, child) {
            final tilt = _tiltAnimation.value * 0.25;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(tilt),
              child: child,
            );
          },
          child: SizedBox(
            width: wheelSize + 40,
            height: wheelSize + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3D shadow beneath
                AnimatedBuilder(
                  animation: _tiltAnimation,
                  builder: (_, __) => Positioned(
                    bottom: 0,
                    child: Container(
                      width: wheelSize * (0.8 + _tiltAnimation.value * 0.2),
                      height: 20 + _tiltAnimation.value * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((60 + _tiltAnimation.value * 80).toInt()),
                            blurRadius: 20 + _tiltAnimation.value * 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Outer glow ring
                Container(
                  width: wheelSize + 30,
                  height: wheelSize + 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeon.withAlpha(_isSpinning ? 70 : 30),
                        blurRadius: _isSpinning ? 50 : 30,
                        spreadRadius: _isSpinning ? 8 : 3,
                      ),
                    ],
                  ),
                ),
                // Wheel
                Transform.rotate(
                  angle: _angle,
                  child: CustomPaint(
                    size: Size(wheelSize, wheelSize),
                    painter: _Wheel3DPainter(
                      items: widget.items,
                      colors: widget.sliceColors ?? _defaultColors,
                      spinProgress: _isSpinning ? 1.0 : 0.0,
                    ),
                  ),
                ),
                // Center hub
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [AppColors.surfaceBright, AppColors.background],
                    ),
                    border: Border.all(color: AppColors.surfaceBright, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 10),
                      BoxShadow(color: AppColors.primaryNeon.withAlpha(40), blurRadius: 12),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.touch_app_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ),
                // Pointer
                Positioned(
                  top: 0,
                  child: CustomPaint(
                    size: const Size(32, 28),
                    painter: _Pointer3DPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _isSpinning ? null : triggerSpin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              gradient: _isSpinning
                  ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade800])
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(50),
              boxShadow: _isSpinning
                  ? null
                  : [
                      BoxShadow(color: AppColors.primary.withAlpha(100), blurRadius: 20, offset: const Offset(0, 6)),
                      BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 30, spreadRadius: -4),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isSpinning ? LucideIcons.loader : LucideIcons.zap, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isSpinning ? 'SPINNING...' : 'SPIN',
                  style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Wheel3DPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;
  final double spinProgress;

  _Wheel3DPainter({required this.items, required this.colors, required this.spinProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = 2 * pi / items.length;

    final borderPaint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Outer ring
    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.surfaceBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);

    for (int i = 0; i < items.length; i++) {
      final baseColor = colors[i % colors.length];
      // 3D shading: lighter at top, darker at bottom
      final startAngle = i * sliceAngle - pi / 2;
      final midAngle = startAngle + sliceAngle / 2;
      final shadeFactor = (sin(midAngle) * 0.15).clamp(-0.2, 0.2);
      final shadedColor = _shadeColor(baseColor, shadeFactor);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [shadedColor.withAlpha(240), shadedColor.withAlpha(180)],
          center: Alignment.topLeft,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        startAngle, sliceAngle, true, paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        startAngle, sliceAngle, true, borderPaint,
      );

      // Inner highlight arc
      final highlightPaint = Paint()
        ..color = Colors.white.withAlpha(20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.6),
        startAngle, sliceAngle, false, highlightPaint,
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
              Shadow(color: Colors.black.withAlpha(200), blurRadius: 6, offset: const Offset(1, 1)),
              Shadow(color: Colors.black.withAlpha(100), blurRadius: 2),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      textPainter.layout(maxWidth: radius * 0.55);
      textPainter.paint(canvas, Offset(radius * 0.28, -textPainter.height / 2));
      canvas.restore();
    }

    // Shiny rim
    canvas.drawCircle(
      center, radius - 1,
      Paint()
        ..color = Colors.white.withAlpha(15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  Color _shadeColor(Color color, double factor) {
    final r = (color.red + factor * 255).clamp(0, 255).toInt();
    final g = (color.green + factor * 255).clamp(0, 255).toInt();
    final b = (color.blue + factor * 255).clamp(0, 255).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  @override
  bool shouldRepaint(covariant _Wheel3DPainter old) => old.spinProgress != spinProgress || old.items != items;
}

class _Pointer3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path, Paint()
      ..shader = const LinearGradient(colors: [Colors.white, Color(0xFFDDB7FF)])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    // Highlight edge
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      const Offset(0, 0),
      Paint()..color = Colors.white.withAlpha(120)..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
