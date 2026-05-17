import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThreeDPlayerAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final bool isSelected;

  const ThreeDPlayerAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 52,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: isSelected ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (_, scale, __) => Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow layer (3D depth)
            Transform.translate(
              offset: const Offset(3, 4),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(40),
                ),
              ),
            ),
            // Main avatar
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withAlpha(220), color.withAlpha(140)],
                  center: const Alignment(-0.3, -0.3),
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : color.withAlpha(120),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: color.withAlpha(80), blurRadius: 12, spreadRadius: -2, offset: const Offset(0, 4)),
                  if (isSelected)
                    BoxShadow(color: color.withAlpha(120), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.36,
                    shadows: [Shadow(color: Colors.black.withAlpha(100), blurRadius: 4, offset: const Offset(1, 1))],
                  ),
                ),
              ),
            ),
            // Specular highlight (top-left shine)
            Positioned(
              top: size * 0.12,
              left: size * 0.18,
              child: Container(
                width: size * 0.28,
                height: size * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.1),
                  gradient: LinearGradient(
                    colors: [Colors.white.withAlpha(80), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
