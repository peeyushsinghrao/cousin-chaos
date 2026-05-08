import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

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
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        if (_isSpinning) {
          _isSpinning = false;
          _calculateWinner();
        }
      }
    });
  }

  void _onTick() {
    setState(() {
      _angle = _controller.value;
    });
    // Haptic tick when crossing a slice boundary
    final sliceAngle = 2 * pi / widget.items.length;
    int currentSlice = (_angle / sliceAngle).floor();
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
    // Pointer is at top center (the arrow). We adjust from the -pi/2 offset used in painting.
    final adjustedAngle = (2 * pi - normalizedAngle + sliceAngle / 2) % (2 * pi);
    int winnerIndex = (adjustedAngle / sliceAngle).floor() % widget.items.length;

    HapticFeedback.heavyImpact();
    widget.onSpinComplete(winnerIndex);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final position = details.localPosition;
    final delta = details.delta;

    final touchVector = position - center;
    final angularDelta = (touchVector.dx * delta.dy - touchVector.dy * delta.dx) /
        touchVector.distanceSquared;

    _controller.value += angularDelta;
  }

  void _onPanEnd(DragEndDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    double velocity = 0;
    if (details.velocity.pixelsPerSecond != Offset.zero) {
      // Estimate angular velocity from linear velocity
      final radius = size.width / 2;
      final linearSpeed = details.velocity.pixelsPerSecond.distance;
      velocity = linearSpeed / radius;
      
      // Determine direction based on cross product
      final touchVector = Offset(0, -radius); // approximate at top
      final linearVelocity = details.velocity.pixelsPerSecond;
      final cross = touchVector.dx * linearVelocity.dy - touchVector.dy * linearVelocity.dx;
      if (cross < 0) velocity = -velocity;
    }

    if (velocity.abs() < 1.5) {
      // Too slow, no spin
      return;
    }

    _isSpinning = true;

    // Add more rotations for dramatic effect
    final extraRotations = 3 + Random().nextInt(3); // 3-5 extra full spins
    final totalVelocity = velocity + (extraRotations * 2 * pi * velocity.sign);

    final simulation = FrictionSimulation(
      0.15, // drag coefficient
      _angle,
      totalVelocity,
    );

    _controller.animateWith(simulation);
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

    return SizedBox(
      width: wheelSize + 40,
      height: wheelSize + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
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
          // Wheel
          GestureDetector(
            onPanUpdate: _isSpinning ? null : _onPanUpdate,
            onPanEnd: _isSpinning ? null : _onPanEnd,
            child: Transform.rotate(
              angle: _angle,
              child: CustomPaint(
                size: Size(wheelSize, wheelSize),
                painter: _WheelPainter(
                  items: widget.items,
                  colors: widget.sliceColors ?? _defaultColors,
                ),
              ),
            ),
          ),
          // Center hub
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(color: AppColors.surfaceBright, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.touch_app_rounded, color: AppColors.textMuted, size: 18),
            ),
          ),
          // Pointer arrow at top
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(32, 28),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
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

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    for (int i = 0; i < items.length; i++) {
      // Alternate between bright and slightly dimmer versions
      final baseColor = colors[i % colors.length];
      paint.color = baseColor;

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

      // Draw text
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
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.items != items;
  }
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
      Paint()..color = Colors.white,
    );

    // Shadow
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
