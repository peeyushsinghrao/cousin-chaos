import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class ThreeDDice extends StatefulWidget {
  final void Function(int result) onRollComplete;
  final Color? color;

  const ThreeDDice({super.key, required this.onRollComplete, this.color});

  @override
  State<ThreeDDice> createState() => _ThreeDDiceState();
}

class _ThreeDDiceState extends State<ThreeDDice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotX;
  late Animation<double> _rotY;
  late Animation<double> _rotZ;
  late Animation<double> _scale;
  bool _rolling = false;
  int _face = 1;
  final _random = Random();

  static const _faces = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
  static const _dots = [1, 2, 3, 4, 5, 6];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _setupAnimations();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _rolling = false);
        widget.onRollComplete(_face);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _setupAnimations() {
    _rotX = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi * 4), weight: 80),
      TweenSequenceItem(tween: Tween(begin: pi * 4, end: pi * 4), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotY = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi * 6), weight: 80),
      TweenSequenceItem(tween: Tween(begin: pi * 6, end: pi * 6), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotZ = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi * 2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: pi * 2, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void roll() {
    if (_rolling) return;
    _face = _dots[_random.nextInt(6)];
    setState(() => _rolling = true);
    _controller.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return GestureDetector(
      onTap: roll,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Transform.scale(
          scale: _rolling ? _scale.value : 1.0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(_rolling ? _rotX.value : 0)
              ..rotateY(_rolling ? _rotY.value : 0)
              ..rotateZ(_rolling ? _rotZ.value : 0),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [color.withAlpha(220), color.withAlpha(120)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: color.withAlpha(180), width: 2),
                boxShadow: [
                  BoxShadow(color: color.withAlpha(80), blurRadius: 16, offset: const Offset(4, 4)),
                  BoxShadow(color: Colors.white.withAlpha(20), blurRadius: 4, offset: const Offset(-2, -2)),
                ],
              ),
              child: Center(
                child: Text(
                  _faces[_face - 1],
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
