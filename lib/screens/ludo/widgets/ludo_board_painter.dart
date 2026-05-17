import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/models/ludo_game_state.dart';
import '../../../core/constants/ludo_data.dart';
import '../../../core/theme/app_colors.dart';

class LudoBoardPainter extends CustomPainter {
  final LudoGameState state;
  const LudoBoardPainter({required this.state});

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7), // Blue
    Color(0xFFEF5350), // Red
    Color(0xFF66BB6A), // Green
    Color(0xFFFFEE58), // Yellow
  ];

  bool _isHomeZone(int col, int row) {
    if (col < 6 && row < 6) return true;
    if (col > 8 && row < 6) return true;
    if (col < 6 && row > 8) return true;
    if (col > 8 && row > 8) return true;
    return false;
  }

  bool _isCentreZone(int col, int row) =>
      col >= 6 && col <= 8 && row >= 6 && row <= 8;

  bool _isHomeColumnSquare(int col, int row) {
    if (col == 7 && row >= 1 && row <= 5) return true;
    if (col == 7 && row >= 9 && row <= 13) return true;
    if (row == 7 && col >= 1 && col <= 5) return true;
    if (row == 7 && col >= 9 && col <= 13) return true;
    return false;
  }

  Color _homeColumnColor(int col, int row) {
    if (col == 7 && row >= 1 && row <= 5) return _playerColors[3]; // Yellow
    if (col == 7 && row >= 9 && row <= 13) return _playerColors[0]; // Blue
    if (row == 7 && col >= 1 && col <= 5) return _playerColors[1]; // Red
    if (row == 7 && col >= 9 && col <= 13) return _playerColors[2]; // Green
    return Colors.transparent;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 15;

    // Board background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF12101E),
    );

    // Grid cells
    for (int row = 0; row < 15; row++) {
      for (int col = 0; col < 15; col++) {
        if (_isHomeZone(col, row)) continue;
        if (_isCentreZone(col, row)) continue;

        final rect = Rect.fromLTWH(
          col * cellSize, row * cellSize, cellSize, cellSize,
        );

        Color fillColor;
        if (_isHomeColumnSquare(col, row)) {
          fillColor = _homeColumnColor(col, row).withAlpha(140);
        } else {
          fillColor = (col + row) % 2 == 0
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLowest;
        }

        canvas.drawRect(rect, Paint()..color = fillColor);
        canvas.drawRect(
          rect,
          Paint()
            ..color = AppColors.outlineVariant.withAlpha(80)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
    }

    _drawHomeZones(canvas, cellSize);
    _drawCentre(canvas, cellSize);
    _drawSafeSquares(canvas, cellSize);
    _drawChaosTiles(canvas, cellSize);
    _drawWormholes(canvas, cellSize);
    _drawJail(canvas, cellSize);
    _drawGift(canvas, cellSize);
    _drawEntryArrows(canvas, cellSize);
  }

  void _drawHomeZones(Canvas canvas, double cellSize) {
    // (startCol, startRow, colorIndex)
    const zones = [
      (0, 0, 0), // Blue top-left
      (9, 0, 1), // Red top-right
      (0, 9, 3), // Yellow bottom-left
      (9, 9, 2), // Green bottom-right
    ];

    for (final (startCol, startRow, colorIdx) in zones) {
      final color = _playerColors[colorIdx];
      final rect = Rect.fromLTWH(
        startCol * cellSize,
        startRow * cellSize,
        6 * cellSize,
        6 * cellSize,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = color.withAlpha(45),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = color.withAlpha(180)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final innerRect = Rect.fromLTWH(
        (startCol + 1) * cellSize,
        (startRow + 1) * cellSize,
        4 * cellSize,
        4 * cellSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
        Paint()..color = color.withAlpha(25),
      );

      // Token slot circles
      final slots = [
        [startCol + 1.5, startRow + 1.5],
        [startCol + 3.5, startRow + 1.5],
        [startCol + 1.5, startRow + 3.5],
        [startCol + 3.5, startRow + 3.5],
      ];
      for (final slot in slots) {
        canvas.drawCircle(
          Offset(slot[0] * cellSize, slot[1] * cellSize),
          cellSize * 0.45,
          Paint()..color = color.withAlpha(35),
        );
        canvas.drawCircle(
          Offset(slot[0] * cellSize, slot[1] * cellSize),
          cellSize * 0.45,
          Paint()
            ..color = color.withAlpha(100)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _drawCentre(Canvas canvas, double cellSize) {
    final cx = 7.5 * cellSize;
    final cy = 7.5 * cellSize;
    final half = 1.5 * cellSize;

    final triangleDefs = [
      (1, [Offset(cx, cy), Offset(cx - half, cy - half), Offset(cx + half, cy - half)]),
      (2, [Offset(cx, cy), Offset(cx + half, cy - half), Offset(cx + half, cy + half)]),
      (3, [Offset(cx, cy), Offset(cx + half, cy + half), Offset(cx - half, cy + half)]),
      (0, [Offset(cx, cy), Offset(cx - half, cy + half), Offset(cx - half, cy - half)]),
    ];

    for (final (colorIdx, pts) in triangleDefs) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = _playerColors[colorIdx].withAlpha(230),
      );
    }

    _drawStar(canvas, Offset(cx, cy), cellSize * 0.4, Colors.white.withAlpha(240));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.42;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSafeSquares(Canvas canvas, double cellSize) {
    for (final pos in kSafeSquares) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      _drawStar(
        canvas,
        Offset(sq[0] * cellSize + cellSize / 2, sq[1] * cellSize + cellSize / 2),
        cellSize * 0.33,
        AppColors.neonYellow.withAlpha(200),
      );
    }
  }

  void _drawChaosTiles(Canvas canvas, double cellSize) {
    for (final pos in kChaosTiles) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      final rect = Rect.fromLTWH(sq[0] * cellSize, sq[1] * cellSize, cellSize, cellSize);
      canvas.drawRect(rect, Paint()..color = const Color(0xFF7C3AED).withAlpha(90));
      canvas.drawRect(rect, Paint()
        ..color = const Color(0xFF7C3AED)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      _drawEmoji(canvas, rect.center.dx, rect.center.dy, cellSize * 0.6, '🌀');
    }
  }

  void _drawWormholes(Canvas canvas, double cellSize) {
    for (final pos in [kWormholeA, kWormholeB]) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      final rect = Rect.fromLTWH(sq[0] * cellSize, sq[1] * cellSize, cellSize, cellSize);
      canvas.drawRect(rect, Paint()..color = AppColors.secondary.withAlpha(55));
      canvas.drawRect(rect, Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      _drawEmoji(canvas, rect.center.dx, rect.center.dy, cellSize * 0.55, '🌀');
    }
  }

  void _drawJail(Canvas canvas, double cellSize) {
    if (kJailSquare >= kLudoMainPath.length) return;
    final sq = kLudoMainPath[kJailSquare];
    final rect = Rect.fromLTWH(sq[0] * cellSize, sq[1] * cellSize, cellSize, cellSize);
    canvas.drawRect(rect, Paint()..color = AppColors.dareRed.withAlpha(55));
    canvas.drawRect(rect, Paint()
      ..color = AppColors.dareRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _drawEmoji(canvas, rect.center.dx, rect.center.dy, cellSize * 0.55, '🔒');
  }

  void _drawGift(Canvas canvas, double cellSize) {
    if (kGiftSquare >= kLudoMainPath.length) return;
    final sq = kLudoMainPath[kGiftSquare];
    final rect = Rect.fromLTWH(sq[0] * cellSize, sq[1] * cellSize, cellSize, cellSize);
    canvas.drawRect(rect, Paint()..color = AppColors.neonGreen.withAlpha(55));
    canvas.drawRect(rect, Paint()
      ..color = AppColors.neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _drawEmoji(canvas, rect.center.dx, rect.center.dy, cellSize * 0.55, '🎁');
  }

  void _drawEntryArrows(Canvas canvas, double cellSize) {
    _drawArrow(canvas, 6.5 * cellSize, 14.2 * cellSize, cellSize * 0.28, -math.pi / 2, _playerColors[0]);
    _drawArrow(canvas, 0.8 * cellSize, 6.5 * cellSize, cellSize * 0.28, 0, _playerColors[1]);
    _drawArrow(canvas, 14.2 * cellSize, 8.5 * cellSize, cellSize * 0.28, math.pi, _playerColors[2]);
    _drawArrow(canvas, 8.5 * cellSize, 0.8 * cellSize, cellSize * 0.28, math.pi / 2, _playerColors[3]);
  }

  void _drawArrow(Canvas canvas, double cx, double cy, double size, double angle, Color color) {
    final path = Path()
      ..moveTo(cx + size * math.cos(angle), cy + size * math.sin(angle))
      ..lineTo(
          cx + size * 0.55 * math.cos(angle + 2.356),
          cy + size * 0.55 * math.sin(angle + 2.356))
      ..lineTo(
          cx + size * 0.55 * math.cos(angle - 2.356),
          cy + size * 0.55 * math.sin(angle - 2.356))
      ..close();
    canvas.drawPath(path, Paint()..color = color.withAlpha(200));
  }

  void _drawEmoji(Canvas canvas, double cx, double cy, double size, String emoji) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: size,
    ))
      ..addText(emoji);
    final para = pb.build()..layout(ui.ParagraphConstraints(width: size * 2));
    canvas.drawParagraph(para, Offset(cx - size, cy - size * 0.75));
  }

  @override
  bool shouldRepaint(LudoBoardPainter old) => true;
}
