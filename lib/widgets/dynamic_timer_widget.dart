import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../core/theme/app_colors.dart';

class DynamicTimerWidget extends StatefulWidget {
  final String text;

  const DynamicTimerWidget({super.key, required this.text});

  static Duration? extractDuration(String text) {
    final RegExp minutesRegex = RegExp(r'(\d+)\s*minute', caseSensitive: false);
    final RegExp secondsRegex = RegExp(r'(\d+)\s*second', caseSensitive: false);
    
    int totalSeconds = 0;
    
    final minMatch = minutesRegex.firstMatch(text);
    if (minMatch != null) {
      totalSeconds += int.parse(minMatch.group(1)!) * 60;
    }
    
    final secMatch = secondsRegex.firstMatch(text);
    if (secMatch != null) {
      totalSeconds += int.parse(secMatch.group(1)!);
    }
    
    if (totalSeconds > 0) return Duration(seconds: totalSeconds);
    return null;
  }

  @override
  State<DynamicTimerWidget> createState() => _DynamicTimerWidgetState();
}

class _DynamicTimerWidgetState extends State<DynamicTimerWidget> with SingleTickerProviderStateMixin {
  late int _initialSeconds;
  late int _currentSeconds;
  Timer? _timer;
  bool _isRunning = false;
  
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    final duration = DynamicTimerWidget.extractDuration(widget.text);
    _initialSeconds = duration?.inSeconds ?? 0;
    _currentSeconds = _initialSeconds;
    
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DynamicTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      final duration = DynamicTimerWidget.extractDuration(widget.text);
      _initialSeconds = duration?.inSeconds ?? 0;
      _currentSeconds = _initialSeconds;
      _isRunning = false;
      _flashController.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_currentSeconds <= 0) return;
      HapticFeedback.mediumImpact();
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
            
            // Flashing animation during last 5 seconds
            if (_currentSeconds <= 5 && _currentSeconds > 0) {
              HapticFeedback.lightImpact();
              _flashController.forward(from: 0.0);
            }
          }
          
          if (_currentSeconds == 0) {
            _timer?.cancel();
            _isRunning = false;
            _onTimerComplete();
          }
        });
      });
    }
  }

  void _onTimerComplete() {
    // Dramatic full screen effect would be triggered here (using an overlay)
    // and heavy haptics/sound
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.vibrate());
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.vibrate());
    
    _showCompletionOverlay();
  }
  
  void _showCompletionOverlay() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, val, child) {
                  return Container(
                    color: AppColors.dareRed.withAlpha((val * 150).toInt()),
                  );
                },
                onEnd: () {
                  Future.delayed(const Duration(milliseconds: 800), () {
                    overlayEntry.remove();
                  });
                },
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
              child: ZoomIn(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'TIME\\'S UP!',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(color: AppColors.dareRed, blurRadius: 20),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentSeconds = _initialSeconds;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_initialSeconds == 0) return const SizedBox.shrink();

    final progress = _initialSeconds > 0 ? _currentSeconds / _initialSeconds : 0.0;
    final isCritical = _currentSeconds <= 5 && _currentSeconds > 0;

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        final glowColor = isCritical 
            ? Color.lerp(AppColors.neonPink, AppColors.dareRed, _flashAnimation.value)!
            : AppColors.neonPink;
            
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: glowColor.withAlpha(50)),
            boxShadow: isCritical ? [
              BoxShadow(
                color: glowColor.withAlpha((_flashAnimation.value * 100).toInt()),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ] : [],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceBright,
                      color: glowColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        _formatTime(_currentSeconds),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isCritical ? glowColor : Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    onTap: _resetTimer,
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                    color: AppColors.surfaceBright,
                    textColor: Colors.white,
                  ),
                  _buildButton(
                    onTap: _toggleTimer,
                    icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    label: _isRunning ? 'Stop' : 'Start',
                    color: _isRunning ? AppColors.dareRed : AppColors.neonGreen,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
