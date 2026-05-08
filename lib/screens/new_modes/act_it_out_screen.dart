import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';

class ActItOutScreen extends StatefulWidget {
  const ActItOutScreen({super.key});

  @override
  State<ActItOutScreen> createState() => _ActItOutScreenState();
}

class _ActItOutScreenState extends State<ActItOutScreen> {
  final Random _random = Random();
  String _currentChallenge = '';
  String _currentCategory = '';
  bool _timerActive = false;
  int _timeLeft = 30;
  Timer? _timer;

  final Map<String, List<String>> _challenges = {
    'Funny': [
      'Act like your mom caught your phone at 2AM',
      'Act like you stepped in dog poop but you are on a date',
      'Act like a monkey trying to understand a smartphone',
    ],
    'Anime': [
      'Act like a character powering up for 3 episodes',
      'Act like you just unlocked the Sharingan',
      'Act like you are doing a JoJo pose during an argument',
    ],
    'School': [
      'Act like you forgot your homework when the teacher asks',
      'Act like you are trying to cheat during an exam',
      'Act like the school bell just rang but the teacher says "The bell does not dismiss you"',
    ],
    'Gaming': [
      'Act like a Free Fire rank push failed',
      'Act like you just found a shiny Pokemon but your battery died',
      'Act like you are raging after a lag spike',
    ],
    'Family': [
      'Act like your dad trying to fix the WiFi router',
      'Act like an aunt gossiping at a wedding',
    ],
    'Cringe': [
      'Act like a TikToker doing a dance in public',
      'Act like an influencer apologizing with a sigh',
    ],
  };

  @override
  void initState() {
    super.initState();
    _nextChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextChallenge() {
    final categories = _challenges.keys.toList();
    _currentCategory = categories[_random.nextInt(categories.length)];
    final list = _challenges[_currentCategory]!;
    _currentChallenge = list[_random.nextInt(list.length)];
    
    _timer?.cancel();
    if (_timerActive) {
      _timeLeft = 30;
      _startTimer();
    } else {
      _timeLeft = 30;
    }
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _timerActive = !_timerActive;
      if (_timerActive) {
        _startTimer();
      } else {
        _timer?.cancel();
        _timeLeft = 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'ACT IT OUT',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonOrange,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _timerActive ? Icons.timer_rounded : Icons.timer_off_rounded,
              color: _timerActive ? AppColors.neonOrange : AppColors.textMuted,
            ),
            onPressed: _toggleTimer,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.neonOrange.withAlpha(40), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            if (_timerActive)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  '00:${_timeLeft.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: _timeLeft <= 5 ? AppColors.dareRed : Colors.white,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: FadeInUp(
                  key: ValueKey(_currentChallenge),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.neonOrange.withAlpha(80), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonOrange.withAlpha(30),
                          blurRadius: 40,
                          spreadRadius: -10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.neonOrange.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentCategory.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neonOrange,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _currentChallenge,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '(Act without speaking!)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _nextChallenge();
                },
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.neonOrange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonOrange.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'NEXT CHALLENGE',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
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
