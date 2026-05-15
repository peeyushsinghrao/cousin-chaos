import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double verticalDistance;
  final double horizontalDistance;

  const FloatAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 6),
    this.verticalDistance = 20,
    this.horizontalDistance = 10,
  });

  @override
  State<FloatAnimation> createState() => _FloatAnimationState();
}

class _FloatAnimationState extends State<FloatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.horizontalDistance * math.sin(_animation.value * math.pi * 2),
            -widget.verticalDistance * math.sin(_animation.value * math.pi),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class PulseGlowAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color glowColor;
  final double minBlur;
  final double maxBlur;

  const PulseGlowAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.glowColor = Colors.purple,
    this.minBlur = 10,
    this.maxBlur = 20,
  });

  @override
  State<PulseGlowAnimation> createState() => _PulseGlowAnimationState();
}

class _PulseGlowAnimationState extends State<PulseGlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final blur = widget.minBlur +
            (widget.maxBlur - widget.minBlur) * _animation.value;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withAlpha(153),
                blurRadius: blur,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class FadeInUpAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  const FadeInUpAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 20),
  });

  @override
  State<FadeInUpAnimation> createState() => _FadeInUpAnimationState();
}

class _FadeInUpAnimationState extends State<FadeInUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white.withAlpha(102),
                Colors.transparent,
              ],
              stops: [
                0.3 + _animation.value * 0.2,
                0.5 + _animation.value * 0.2,
                0.7 + _animation.value * 0.2,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class OrbitAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double radius;
  final bool clockwise;

  const OrbitAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 12),
    this.radius = 120,
    this.clockwise = true,
  });

  @override
  State<OrbitAnimation> createState() => _OrbitAnimationState();
}

class _OrbitAnimationState extends State<OrbitAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = widget.clockwise
            ? _animation.value
            : -_animation.value;
        return Transform.translate(
          offset: Offset(
            widget.radius * math.cos(angle),
            widget.radius * math.sin(angle),
          ),
          child: Transform.rotate(
            angle: -angle,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class ButtonPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color pulseColor;

  const ButtonPulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.pulseColor = Colors.purple,
  });

  @override
  State<ButtonPulseAnimation> createState() => _ButtonPulseAnimationState();
}

class _ButtonPulseAnimationState extends State<ButtonPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final spread = _animation.value < 0.7
            ? _animation.value * 20
            : (1 - _animation.value) * 20;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withAlpha((0.4 * (1 - _animation.value) * 255).round()),
                blurRadius: 0,
                spreadRadius: spread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 15),
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.45 + _animation.value * 0.9, 0.5),
              end: Alignment(0.45 - _animation.value * 0.9, 0.5),
              colors: const [
                Color(0xFF17111F),
                Color(0xFF2C0051),
                Color(0xFF001F2A),
                Color(0xFF17111F),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
