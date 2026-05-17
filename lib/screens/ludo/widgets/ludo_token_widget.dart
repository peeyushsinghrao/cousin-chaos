import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/ludo_token.dart';
import '../../../core/models/ludo_player.dart';
import '../../../core/constants/ludo_data.dart';

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

  static const List<Color> _neonColors = [
    Color(0xFF4FC3F7), // Blue
    Color(0xFFEF5350), // Red
    Color(0xFF66BB6A), // Green
    Color(0xFFFFEE58), // Yellow
  ];

  Color get _color => _neonColors[token.playerIndex];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: cellSize * 0.75,
        height: cellSize * 0.75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color.withAlpha(220),
          border: Border.all(
            color: isSelectable ? Colors.white : _color.withAlpha(120),
            width: isSelectable ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _color.withAlpha(isSelectable ? 180 : 70),
              blurRadius: isSelectable ? 14 : 6,
              spreadRadius: isSelectable ? 3 : 0,
            ),
          ],
        ),
        child: Stack(alignment: Alignment.center, children: [
          Text(
            LudoPlayer.colorNames[token.playerIndex][0],
            style: GoogleFonts.poppins(
              fontSize: cellSize * 0.28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              LudoToken.personalityEmoji(token.personality),
              style: TextStyle(fontSize: cellSize * 0.2),
            ),
          ),
          if (token.isInJail)
            Positioned.fill(
              child: CustomPaint(painter: _JailBarsPainter()),
            ),
          if (token.curseRevealed)
            Positioned(
              top: 0,
              left: 0,
              child: Text('💀', style: TextStyle(fontSize: cellSize * 0.2)),
            ),
          if (isSelectable)
            Positioned.fill(
              child: _PulseIndicator(color: _color),
            ),
        ]),
      ),
    );
  }
}

Offset tokenOffset(LudoToken token, double cellSize) {
  if (token.state == TokenState.home) {
    final homeOrigins = [
      [0.0, 0.0],
      [9.0, 0.0],
      [9.0, 9.0],
      [0.0, 9.0],
    ];
    final slotOffsets = [
      const Offset(1.5, 1.5),
      const Offset(3.5, 1.5),
      const Offset(1.5, 3.5),
      const Offset(3.5, 3.5),
    ];
    final origin = homeOrigins[token.playerIndex];
    final slot = slotOffsets[token.tokenIndex];
    return Offset(
      (origin[0] + slot.dx) * cellSize - cellSize * 0.375,
      (origin[1] + slot.dy) * cellSize - cellSize * 0.375,
    );
  }

  if (token.pathPosition >= 52) {
    final colIndex = token.pathPosition - 52;
    final cols = [kBlueHomeCol, kRedHomeCol, kGreenHomeCol, kYellowHomeCol];
    final sq = cols[token.playerIndex][colIndex.clamp(0, 5)];
    final stackOffset = [
      const Offset(0, 0),
      const Offset(2, 2),
      const Offset(-2, -2),
      const Offset(2, -2),
    ][token.tokenIndex];
    return Offset(
      sq[0] * cellSize + stackOffset.dx - cellSize * 0.375,
      sq[1] * cellSize + stackOffset.dy - cellSize * 0.375,
    );
  }

  if (token.pathPosition < 0 || token.pathPosition >= kLudoMainPath.length) {
    return const Offset(-100, -100);
  }

  final sq = kLudoMainPath[token.pathPosition];
  final offsets = [
    const Offset(0, 0),
    const Offset(4, 0),
    const Offset(0, 4),
    const Offset(4, 4),
  ];
  return Offset(
    sq[0] * cellSize + offsets[token.tokenIndex].dx - cellSize * 0.375,
    sq[1] * cellSize + offsets[token.tokenIndex].dy - cellSize * 0.375,
  );
}

class _JailBarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(160)
      ..strokeWidth = size.width * 0.12;
    final count = 3;
    for (int i = 0; i < count; i++) {
      final x = size.width * (i + 1) / (count + 1);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_JailBarsPainter old) => false;
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withAlpha((_anim.value * 200).toInt()),
            width: 2,
          ),
        ),
      ),
    );
  }
}
