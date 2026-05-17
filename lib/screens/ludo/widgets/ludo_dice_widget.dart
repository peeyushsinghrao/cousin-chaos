import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LudoDiceWidget extends StatefulWidget {
  final int value;
  final int? value2;
  final bool isRolling;
  final bool isPowerRoll;
  final bool isSpeedRound;
  final double? speedProgress;
  final VoidCallback? onRoll;
  final ValueChanged<int>? onPickDice; // 0 = primary, 1 = secondary

  const LudoDiceWidget({
    super.key,
    required this.value,
    this.value2,
    this.isRolling = false,
    this.isPowerRoll = false,
    this.isSpeedRound = false,
    this.speedProgress,
    this.onRoll,
    this.onPickDice,
  });

  @override
  State<LudoDiceWidget> createState() => _LudoDiceWidgetState();
}

class _LudoDiceWidgetState extends State<LudoDiceWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  int _displayValue = 1;
  int _displayValue2 = 1;
  Timer? _cycleTimer;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _displayValue2 = widget.value2 ?? 1;
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);
  }

  @override
  void didUpdateWidget(LudoDiceWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRolling && !old.isRolling) {
      _startRolling();
    } else if (!widget.isRolling && old.isRolling) {
      _stopRolling();
    }
    if (!widget.isRolling) {
      _displayValue = widget.value;
      _displayValue2 = widget.value2 ?? 1;
    }
  }

  void _startRolling() {
    _shakeController.repeat(reverse: true);
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) {
        setState(() {
          _displayValue = 1 + _rng.nextInt(6);
          _displayValue2 = 1 + _rng.nextInt(6);
        });
      }
    });
  }

  void _stopRolling() {
    _cycleTimer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
    if (mounted) {
      setState(() {
        _displayValue = widget.value;
        _displayValue2 = widget.value2 ?? 1;
      });
    }
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPowerRoll && widget.value2 != null && widget.onPickDice != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDie(_displayValue, 0),
          const SizedBox(width: 12),
          _buildDie(_displayValue2, 1),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          sin(_shakeAnim.value * pi * 8) * 4,
          0,
        ),
        child: child,
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onRoll,
            child: _buildDieContainer(_displayValue, widget.onRoll == null),
          ),
          if (widget.isSpeedRound && widget.speedProgress != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _CountdownRingPainter(
                  progress: widget.speedProgress!,
                  color: widget.speedProgress! > 0.4
                      ? AppColors.neonGreen
                      : AppColors.dareRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDie(int val, int index) {
    return GestureDetector(
      onTap: () => widget.onPickDice?.call(index),
      child: _buildDieContainer(val, false),
    );
  }

  Widget _buildDieContainer(int val, bool disabled) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: disabled
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: disabled
              ? AppColors.outlineVariant
              : AppColors.primary.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: disabled
          ? Center(
              child: Text(
                '🎲',
                style: TextStyle(fontSize: 28, color: AppColors.textMuted),
              ),
            )
          : CustomPaint(
              painter: _DiceFacePainter(
                value: val,
                pipColor: AppColors.primary,
              ),
            ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color pipColor;

  const _DiceFacePainter({required this.value, required this.pipColor});

  static const Map<int, List<Offset>> _pipPositions = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.25, 0.25), Offset(0.75, 0.75)],
    3: [Offset(0.25, 0.25), Offset(0.5, 0.5), Offset(0.75, 0.75)],
    4: [
      Offset(0.25, 0.25), Offset(0.75, 0.25),
      Offset(0.25, 0.75), Offset(0.75, 0.75)
    ],
    5: [
      Offset(0.25, 0.25), Offset(0.75, 0.25), Offset(0.5, 0.5),
      Offset(0.25, 0.75), Offset(0.75, 0.75)
    ],
    6: [
      Offset(0.25, 0.2), Offset(0.75, 0.2),
      Offset(0.25, 0.5), Offset(0.75, 0.5),
      Offset(0.25, 0.8), Offset(0.75, 0.8)
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final positions = _pipPositions[value.clamp(1, 6)] ?? [];
    final pipRadius = size.width * 0.09;
    for (final pos in positions) {
      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height),
        pipRadius,
        Paint()..color = pipColor,
      );
    }
  }

  @override
  bool shouldRepaint(_DiceFacePainter old) => old.value != value;
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _CountdownRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) => old.progress != progress;
}

class LudoDiceLabel extends StatelessWidget {
  final int value;
  const LudoDiceLabel({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      ),
    );
  }
}
