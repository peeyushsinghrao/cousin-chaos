import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';

class BombPassScreen extends StatefulWidget {
  const BombPassScreen({super.key});

  @override
  State<BombPassScreen> createState() => _BombPassScreenState();
}

class _BombPassScreenState extends State<BombPassScreen> {
  final Random _random = Random();
  bool _isPlaying = false;
  bool _isExploded = false;
  String _currentTask = '';
  
  Timer? _bombTimer;
  Timer? _tickTimer;
  int _timeUntilExplosion = 0;

  final List<String> _tasks = [
    'Name 3 countries starting with the same letter',
    'Do your best celebrity impression',
    'Say the alphabet backwards as fast as you can',
    'Tell an embarrassing story in 10 seconds',
    'Do 10 jumping jacks right now',
    'Speak in an accent until the next turn',
    'Name 5 movies in 5 seconds',
    'Sing the first line of any song',
    'Do your best robot dance for 5 seconds',
    'Make everyone laugh without speaking',
  ];

  @override
  void dispose() {
    _bombTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isExploded = false;
    });
    
    _nextTask();

    // Bomb explodes between 15 and 45 seconds
    _timeUntilExplosion = _random.nextInt(31) + 15;
    
    _bombTimer = Timer(Duration(seconds: _timeUntilExplosion), _explodeBomb);
    
    // Ticking effect gets faster
    _scheduleTick(_timeUntilExplosion.toDouble());
  }

  void _scheduleTick(double timeLeft) {
    if (!_isPlaying || _isExploded) return;
    
    HapticFeedback.selectionClick();
    
    // Calculate next tick interval (gets faster as time runs out)
    double ratio = timeLeft / 45.0; // max time 45s
    int delayMs = max(100, (1000 * ratio).toInt());
    
    _tickTimer = Timer(Duration(milliseconds: delayMs), () {
      _scheduleTick(timeLeft - (delayMs / 1000.0));
    });
  }

  void _nextTask() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTask = _tasks[_random.nextInt(_tasks.length)];
    });
  }

  void _explodeBomb() {
    _tickTimer?.cancel();
    HapticFeedback.vibrate();
    
    for(int i=0; i<10; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if(mounted) HapticFeedback.heavyImpact();
      });
    }

    setState(() {
      _isExploded = true;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isExploded) return _buildExplosionScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BOMB PASS',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.dareRed,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [_isPlaying ? AppColors.dareRed.withAlpha(50) : AppColors.truthBlue.withAlpha(40), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPlaying) ...[
              const Icon(Icons.local_fire_department_rounded, color: AppColors.dareRed, size: 120),
              const SizedBox(height: 32),
              Text(
                'TICK TOCK...',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'The bomb is hidden. Complete the task and pass the phone. Don\'t be the one holding it when it explodes!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.dareRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dareRed.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'LIGHT THE FUSE',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            if (_isPlaying) ...[
              Pulse(
                infinite: true,
                duration: const Duration(milliseconds: 500),
                child: const Icon(Icons.local_fire_department_rounded, color: AppColors.dareRed, size: 150),
              ),
              const SizedBox(height: 48),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.dareRed, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT TASK',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dareRed,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentTask,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _nextTask,
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.neonYellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonYellow.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'DONE! PASS DEVICE',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplosionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Flash(
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.dareRedDark, size: 150),
              Text(
                'BOOM!',
                style: GoogleFonts.poppins(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dareRed,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'YOU LOSE!',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Take a penalty.',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 64),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExploded = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
