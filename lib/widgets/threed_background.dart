import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ThreeDBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const ThreeDBackground({super.key, required this.child, this.colors});

  @override
  State<ThreeDBackground> createState() => _ThreeDBackgroundState();
}

class _ThreeDBackgroundState extends State<ThreeDBackground> with TickerProviderStateMixin {
  late List<_FloatingShape> _shapes;
  late AnimationController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _shapes = List.generate(12, (_) => _FloatingShape.random(_random));
    _controller.addListener(() {
      if (mounted) setState(() {
        for (final s in _shapes) s.update();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? [AppColors.primary, AppColors.secondary, AppColors.tertiary];
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ShapesPainter(_shapes, colors),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _FloatingShape {
  double x, y, z;
  double vx, vy, vz;
  double size;
  int type;
  double rotation;
  double rotationSpeed;

  _FloatingShape({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.size,
    required this.type,
    required this.rotation,
    required this.rotationSpeed,
  });

  factory _FloatingShape.random(Random r) => _FloatingShape(
    x: r.nextDouble(),
    y: r.nextDouble(),
    z: r.nextDouble(),
    vx: (r.nextDouble() - 0.5) * 0.0008,
    vy: (r.nextDouble() - 0.5) * 0.0008,
    vz: (r.nextDouble() - 0.5) * 0.002,
    size: 8 + r.nextDouble() * 20,
    type: r.nextInt(3),
    rotation: r.nextDouble() * pi * 2,
    rotationSpeed: (r.nextDouble() - 0.5) * 0.03,
  );

  void update() {
    x += vx;
    y += vy;
    z += vz;
    rotation += rotationSpeed;
    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;
    if (z < 0 || z > 1) vz *= -1;
  }
}

class _ShapesPainter extends CustomPainter {
  final List<_FloatingShape> shapes;
  final List<Color> colors;

  _ShapesPainter(this.shapes, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < shapes.length; i++) {
      final s = shapes[i];
      final scale = 0.5 + s.z * 0.8;
      final alpha = (15 + s.z * 30).toInt().clamp(5, 45);
      final color = colors[i % colors.length].withAlpha(alpha);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + s.z;

      final cx = s.x * size.width;
      final cy = s.y * size.height;
      final r = s.size * scale;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(s.rotation);

      switch (s.type) {
        case 0: // cube wireframe (projected square with depth)
          final rect = Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2);
          canvas.drawRect(rect, paint);
          final offset = r * 0.4;
          canvas.drawRect(rect.translate(offset, -offset), paint..color = color.withAlpha((alpha * 0.6).toInt()));
          for (final corner in [Offset(-r, -r), Offset(r, -r), Offset(r, r), Offset(-r, r)]) {
            canvas.drawLine(corner, corner + Offset(offset, -offset), paint);
          }
          break;
        case 1: // diamond
          final path = Path()
            ..moveTo(0, -r)
            ..lineTo(r * 0.6, 0)
            ..lineTo(0, r)
            ..lineTo(-r * 0.6, 0)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case 2: // triangle 3d
          final triPath = Path()
            ..moveTo(0, -r)
            ..lineTo(r, r * 0.6)
            ..lineTo(-r, r * 0.6)
            ..close();
          canvas.drawPath(triPath, paint);
          canvas.drawLine(Offset(0, -r), Offset(r * 0.3, r * 0.1), paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShapesPainter old) => true;
}
