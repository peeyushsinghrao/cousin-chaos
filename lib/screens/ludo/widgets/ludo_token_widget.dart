import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/ludo_token.dart';
import '../../../core/constants/ludo_data.dart';

/// Ludo King–style 3-D circular token.
class LudoTokenWidget extends StatelessWidget {
  final LudoToken token;
  final double cellSize;
  final bool isSelectable;
  final VoidCallback? onTap;

  const LudoTokenWidget({
    super.key,
    required this.token,
    required this.cellSize,
    this.isSelectable = false,
    this.onTap,
  });

  // Vivid Ludo King palette
  static const List<Color> _base = [
    Color(0xFF1565C0), // Blue
    Color(0xFFC62828), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFFF9A825), // Yellow
  ];
  static const List<Color> _light = [
    Color(0xFF90CAF9),
    Color(0xFFEF9A9A),
    Color(0xFFA5D6A7),
    Color(0xFFFFE082),
  ];
  static const List<Color> _shine = [
    Color(0xFFBBDEFB),
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
  ];

  @override
  Widget build(BuildContext context) {
    final size = cellSize * 0.70;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          // Pulsing selection ring
          if (isSelectable)
            _PulseRing(color: _base[token.playerIndex], size: size),

          // Drop shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isSelectable ? 130 : 80),
                  blurRadius: isSelectable ? 10 : 5,
                  offset: const Offset(0, 3),
                ),
                if (isSelectable)
                  BoxShadow(
                    color: _base[token.playerIndex].withAlpha(160),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),

          // Main token body — gradient for 3-D look
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 0.85,
                colors: [
                  _shine[token.playerIndex],
                  _light[token.playerIndex],
                  _base[token.playerIndex],
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              border: Border.all(
                color: isSelectable
                    ? Colors.white
                    : _base[token.playerIndex].withAlpha(180),
                width: isSelectable ? 2.0 : 1.2,
              ),
            ),
          ),

          // Inner white dome highlight
          Positioned(
            top: size * 0.12,
            left: size * 0.18,
            child: Container(
              width: size * 0.38,
              height: size * 0.26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.14),
                color: Colors.white.withAlpha(120),
              ),
            ),
          ),

          // Jail bars overlay
          if (token.isInJail)
            ClipOval(
              child: SizedBox(
                width: size, height: size,
                child: CustomPaint(painter: _JailBarsPainter()),
              ),
            ),

          // Curse skull
          if (token.curseRevealed)
            Positioned(
              top: 0, right: 0,
              child: Text('💀',
                  style: TextStyle(fontSize: size * 0.32, height: 1)),
            ),
        ]),
      ),
    );
  }
}

/// Calculates absolute board position (top-left) of a token.
Offset tokenOffset(LudoToken token, double cellSize) {
  final half = cellSize / 2;

  if (token.state == TokenState.home) {
    // Home zone origins (top-left corner of the 6×6 zone)
    const origins = [
      [0.0, 0.0], // Blue  top-left
      [9.0, 0.0], // Red   top-right
      [9.0, 9.0], // Green bottom-right
      [0.0, 9.0], // Yellow bottom-left
    ];
    // 4 slot positions inside the zone (centred in each 2×2 quarter)
    const slots = [
      Offset(1.75, 1.75),
      Offset(4.25, 1.75),
      Offset(1.75, 4.25),
      Offset(4.25, 4.25),
    ];
    final o = origins[token.playerIndex];
    final s = slots[token.tokenIndex];
    return Offset(
      (o[0] + s.dx) * cellSize - cellSize * 0.35,
      (o[1] + s.dy) * cellSize - cellSize * 0.35,
    );
  }

  if (token.pathPosition >= 52) {
    // Inside home column
    final colIndex = (token.pathPosition - 52).clamp(0, 5);
    const cols = [kBlueHomeCol, kRedHomeCol, kGreenHomeCol, kYellowHomeCol];
    final sq = cols[token.playerIndex][colIndex];
    // Stack 4 tokens with tiny offset so they don't perfectly overlap
    const stackDx = [0.0,  4.0, -4.0,  0.0];
    const stackDy = [0.0, -4.0,  0.0,  4.0];
    return Offset(
      sq[0] * cellSize + stackDx[token.tokenIndex] - cellSize * 0.35,
      sq[1] * cellSize + stackDy[token.tokenIndex] - cellSize * 0.35,
    );
  }

  if (token.pathPosition < 0 || token.pathPosition >= kLudoMainPath.length) {
    return const Offset(-200, -200); // off-screen
  }

  final sq = kLudoMainPath[token.pathPosition];
  // Slightly stagger multiple tokens on same cell
  const dx = [0.0,  3.0, -3.0,  0.0];
  const dy = [0.0, -3.0,  0.0,  3.0];
  return Offset(
    sq[0] * cellSize + dx[token.tokenIndex] + half * 0.15,
    sq[1] * cellSize + dy[token.tokenIndex] + half * 0.15,
  );
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _JailBarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withAlpha(150)
      ..strokeWidth = size.width * 0.10;
    for (int i = 1; i <= 3; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_JailBarsPainter old) => false;
}

class _PulseRing extends StatefulWidget {
  final Color color;
  final double size;
  const _PulseRing({required this.color, required this.size});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + _ctrl.value * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withAlpha((180 * (1 - _ctrl.value)).toInt()),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Draw a 5-pointed star at [center] with outer [radius].
void drawStar(Canvas canvas, Offset center, double radius, Color color) {
  final path = Path();
  for (int i = 0; i < 10; i++) {
    final r = i.isEven ? radius : radius * 0.45;
    final angle = (i * 36 - 90) * math.pi / 180;
    final x = center.dx + r * math.cos(angle);
    final y = center.dy + r * math.sin(angle);
    if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
  }
  path.close();
  canvas.drawPath(path, Paint()..color = color);
}
