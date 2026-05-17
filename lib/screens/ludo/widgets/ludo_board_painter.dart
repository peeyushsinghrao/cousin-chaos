import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/models/ludo_game_state.dart';
import '../../../core/constants/ludo_data.dart';

/// Ludo King–style board painter.
/// Path cells: white. Home zones: solid bright colour.
/// Home columns: solid player colour. Centre: 4 triangles + star.
class LudoBoardPainter extends CustomPainter {
  final LudoGameState state;
  const LudoBoardPainter({required this.state});

  // Ludo King vivid colours ─────────────────────────────────────────────────
  static const Color _blue   = Color(0xFF1565C0);
  static const Color _red    = Color(0xFFC62828);
  static const Color _green  = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF9A825);

  static const List<Color> _pc = [_blue, _red, _green, _yellow];

  // Lighter tints for home zone fills
  static const List<Color> _lt = [
    Color(0xFF90CAF9), // blue light
    Color(0xFFEF9A9A), // red light
    Color(0xFFA5D6A7), // green light
    Color(0xFFFFE082), // yellow light
  ];

  // Path cell colours
  static const Color _cellWhite = Color(0xFFF8F5EE);
  static const Color _cellAlt   = Color(0xFFEDE8DC);
  static const Color _border    = Color(0xFFBBB5A5);

  // ─── helpers ──────────────────────────────────────────────────────────────

  bool _isCorner(int col, int row) {
    if (col < 6 && row < 6)   return true;
    if (col > 8 && row < 6)   return true;
    if (col < 6 && row > 8)   return true;
    if (col > 8 && row > 8)   return true;
    return false;
  }

  bool _isCentre(int col, int row) =>
      col >= 6 && col <= 8 && row >= 6 && row <= 8;

  bool _isHomeCol(int col, int row) {
    if (col == 7 && row >= 1 && row <= 5)   return true; // yellow col
    if (col == 7 && row >= 9 && row <= 13)  return true; // blue col
    if (row == 7 && col >= 1 && col <= 5)   return true; // red row
    if (row == 7 && col >= 9 && col <= 13)  return true; // green row
    return false;
  }

  Color _homeColColor(int col, int row) {
    if (col == 7 && row >= 1 && row <= 5)  return _yellow;
    if (col == 7 && row >= 9 && row <= 13) return _blue;
    if (row == 7 && col >= 1 && col <= 5)  return _red;
    if (row == 7 && col >= 9 && col <= 13) return _green;
    return Colors.transparent;
  }

  // ─── main paint ───────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final cs = size.width / 15; // cell size

    // Board background (a deep green table feel)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1F2E),
    );

    // ── Path cells ──────────────────────────────────────────────────────────
    for (int row = 0; row < 15; row++) {
      for (int col = 0; col < 15; col++) {
        if (_isCorner(col, row)) continue;
        if (_isCentre(col, row)) continue;

        final rect = Rect.fromLTWH(col * cs, row * cs, cs, cs);

        Color fill;
        if (_isHomeCol(col, row)) {
          fill = _homeColColor(col, row);
        } else {
          fill = (col + row).isEven ? _cellWhite : _cellAlt;
        }

        canvas.drawRect(rect, Paint()..color = fill);
        canvas.drawRect(rect, Paint()
          ..color = _border.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6);
      }
    }

    _drawCorners(canvas, cs);
    _drawCentre(canvas, cs);
    _drawSafeSquares(canvas, cs);
    _drawChaosTiles(canvas, cs);
    _drawWormholes(canvas, cs);
    _drawJailSquare(canvas, cs);
    _drawGiftSquare(canvas, cs);
    _drawEntryArrows(canvas, cs);
    _drawBoardBorder(canvas, size);
  }

  // ─── Corner home zones ────────────────────────────────────────────────────

  void _drawCorners(Canvas canvas, double cs) {
    // (col, row, playerIdx)
    const zones = [
      (0, 0, 0), // Blue   top-left
      (9, 0, 1), // Red    top-right
      (0, 9, 3), // Yellow bottom-left
      (9, 9, 2), // Green  bottom-right
    ];

    for (final (sc, sr, idx) in zones) {
      final color = _pc[idx];
      final light = _lt[idx];

      // Solid zone fill
      final zoneRect = Rect.fromLTWH(sc * cs, sr * cs, 6 * cs, 6 * cs);
      canvas.drawRect(zoneRect, Paint()..color = color);

      // White inner panel
      const pad = 0.15;
      final innerRect = Rect.fromLTWH(
        (sc + pad) * cs, (sr + pad) * cs,
        (6 - pad * 2) * cs, (6 - pad * 2) * cs,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(innerRect, Radius.circular(cs * 0.4)),
        Paint()..color = light,
      );

      // White rounded rect inside that
      final whiteRect = Rect.fromLTWH(
        (sc + 0.85) * cs, (sr + 0.85) * cs,
        (6 - 1.7) * cs, (6 - 1.7) * cs,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(whiteRect, Radius.circular(cs * 0.35)),
        Paint()..color = Colors.white.withAlpha(200),
      );

      // 4 token slot circles
      final slots = [
        [sc + 1.75, sr + 1.75],
        [sc + 4.25, sr + 1.75],
        [sc + 1.75, sr + 4.25],
        [sc + 4.25, sr + 4.25],
      ];
      for (final s in slots) {
        final cx = s[0] * cs;
        final cy = s[1] * cs;

        // Shadow
        canvas.drawCircle(Offset(cx + 2, cy + 2), cs * 0.52,
            Paint()..color = Colors.black.withAlpha(60));

        // Outer ring (player colour)
        canvas.drawCircle(Offset(cx, cy), cs * 0.52,
            Paint()..color = color);

        // Middle ring (lighter)
        canvas.drawCircle(Offset(cx, cy), cs * 0.41,
            Paint()..color = light);

        // Inner white circle
        canvas.drawCircle(Offset(cx, cy), cs * 0.28,
            Paint()..color = Colors.white.withAlpha(160));
      }
    }
  }

  // ─── Centre ───────────────────────────────────────────────────────────────

  void _drawCentre(Canvas canvas, double cs) {
    final cx = 7.5 * cs;
    final cy = 7.5 * cs;
    final half = 1.5 * cs;

    // White base
    final centreRect = Rect.fromLTWH(6 * cs, 6 * cs, 3 * cs, 3 * cs);
    canvas.drawRect(centreRect, Paint()..color = Colors.white);

    // 4 triangles — each pointing inward toward centre:
    // top = yellow (matches yellow col above), right = green, bottom = blue, left = red
    // We match home-column colours: top→yellow, right→green, bottom→blue, left→red
    final triangles = [
      (_yellow, [Offset(cx, cy), Offset(cx - half, cy - half), Offset(cx + half, cy - half)]),
      (_green,  [Offset(cx, cy), Offset(cx + half, cy - half), Offset(cx + half, cy + half)]),
      (_blue,   [Offset(cx, cy), Offset(cx + half, cy + half), Offset(cx - half, cy + half)]),
      (_red,    [Offset(cx, cy), Offset(cx - half, cy + half), Offset(cx - half, cy - half)]),
    ];

    for (final (col, pts) in triangles) {
      final p = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();
      canvas.drawPath(p, Paint()..color = col);
    }

    // White star in centre
    _drawStar(canvas, Offset(cx, cy), cs * 0.42, Colors.white);
    // Small coloured dot
    canvas.drawCircle(Offset(cx, cy), cs * 0.12,
        Paint()..color = Colors.amber.shade300);
  }

  // ─── Safe squares ─────────────────────────────────────────────────────────

  void _drawSafeSquares(Canvas canvas, double cs) {
    for (final pos in kSafeSquares) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      final rect = Rect.fromLTWH(sq[0] * cs, sq[1] * cs, cs, cs);
      // Green tinted background
      canvas.drawRect(rect, Paint()..color = const Color(0xFF81C784).withAlpha(160));
      _drawStar(
        canvas,
        Offset(sq[0] * cs + cs / 2, sq[1] * cs + cs / 2),
        cs * 0.32,
        Colors.white.withAlpha(240),
      );
    }
  }

  // ─── Chaos tiles ──────────────────────────────────────────────────────────

  void _drawChaosTiles(Canvas canvas, double cs) {
    for (final pos in kChaosTiles) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      final rect = Rect.fromLTWH(sq[0] * cs, sq[1] * cs, cs, cs);
      canvas.drawRect(rect, Paint()..color = const Color(0xFF7C3AED));
      canvas.drawRect(rect, Paint()
        ..color = Colors.white.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);
      _drawEmoji(canvas, rect.center.dx, rect.center.dy, cs * 0.58, '🌀');
    }
  }

  // ─── Wormholes ────────────────────────────────────────────────────────────

  void _drawWormholes(Canvas canvas, double cs) {
    for (final pos in [kWormholeA, kWormholeB]) {
      if (pos >= kLudoMainPath.length) continue;
      final sq = kLudoMainPath[pos];
      final rect = Rect.fromLTWH(sq[0] * cs, sq[1] * cs, cs, cs);
      canvas.drawRect(rect, Paint()..color = const Color(0xFF0D47A1));
      canvas.drawRect(rect, Paint()
        ..color = Colors.cyan.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      _drawEmoji(canvas, rect.center.dx, rect.center.dy, cs * 0.54, '🌀');
    }
  }

  // ─── Jail square ──────────────────────────────────────────────────────────

  void _drawJailSquare(Canvas canvas, double cs) {
    if (kJailSquare >= kLudoMainPath.length) return;
    final sq = kLudoMainPath[kJailSquare];
    final rect = Rect.fromLTWH(sq[0] * cs, sq[1] * cs, cs, cs);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFB71C1C));
    canvas.drawRect(rect, Paint()
      ..color = Colors.orange.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _drawEmoji(canvas, rect.center.dx, rect.center.dy, cs * 0.54, '🔒');
  }

  // ─── Gift square ──────────────────────────────────────────────────────────

  void _drawGiftSquare(Canvas canvas, double cs) {
    if (kGiftSquare >= kLudoMainPath.length) return;
    final sq = kLudoMainPath[kGiftSquare];
    final rect = Rect.fromLTWH(sq[0] * cs, sq[1] * cs, cs, cs);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF1B5E20));
    canvas.drawRect(rect, Paint()
      ..color = Colors.greenAccent.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _drawEmoji(canvas, rect.center.dx, rect.center.dy, cs * 0.54, '🎁');
  }

  // ─── Entry arrows ─────────────────────────────────────────────────────────

  void _drawEntryArrows(Canvas canvas, double cs) {
    // Blue (player 0) enters from bottom going up at col 6
    _drawArrow(canvas, 6.5 * cs, 13.5 * cs, cs * 0.3, -math.pi / 2, _blue);
    // Red (player 1) enters from left going right at row 8 = 8 → square 13 is [0,8]
    _drawArrow(canvas, 0.5 * cs, 8.5 * cs, cs * 0.3, 0, _red);
    // Green (player 2) enters from top going down at col 8 → square 26 is [8,0]
    _drawArrow(canvas, 8.5 * cs, 0.5 * cs, cs * 0.3, math.pi / 2, _green);
    // Yellow (player 3) enters from right going left at row 6 → square 39 is [14,6]
    _drawArrow(canvas, 13.5 * cs, 6.5 * cs, cs * 0.3, math.pi, _yellow);
  }

  void _drawArrow(Canvas canvas, double cx, double cy, double sz, double angle, Color color) {
    final p = Path()
      ..moveTo(cx + sz * math.cos(angle), cy + sz * math.sin(angle))
      ..lineTo(cx + sz * 0.5 * math.cos(angle + 2.356),
               cy + sz * 0.5 * math.sin(angle + 2.356))
      ..lineTo(cx + sz * 0.5 * math.cos(angle - 2.356),
               cy + sz * 0.5 * math.sin(angle - 2.356))
      ..close();
    canvas.drawPath(p, Paint()..color = color.withAlpha(220));
  }

  // ─── Board border / frame ─────────────────────────────────────────────────

  void _drawBoardBorder(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.white.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.42;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawEmoji(Canvas canvas, double cx, double cy, double sz, String emoji) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: sz,
    ))..addText(emoji);
    final para = pb.build()..layout(ui.ParagraphConstraints(width: sz * 2));
    canvas.drawParagraph(para, Offset(cx - sz, cy - sz * 0.75));
  }

  @override
  bool shouldRepaint(LudoBoardPainter old) => true;
}
