import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_icon.dart';
import '../../services/preferences_service.dart';
import '../../core/constants/random_data.dart';
import '../../models/pack.dart'; // We'll reuse GameCardPrompt or create simple strings

class RandomChallengeScreen extends StatefulWidget {
  const RandomChallengeScreen({super.key});

  @override
  State<RandomChallengeScreen> createState() => _RandomChallengeScreenState();
}

class _RandomChallengeScreenState extends State<RandomChallengeScreen> with SingleTickerProviderStateMixin {
  final List<String> _challenges = RandomData.challenges;
  String? _currentChallenge;
  bool _isShaking = false;
  bool _isRevealing = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _shakeAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _startShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (_isRevealing) return;

      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      // Gravity is ~9.8, so an acceleration > 15 is a strong shake
      if (acceleration > 15.0 && !_isShaking) {
        _triggerRandomChallenge();
      }
    });
  }

  Future<void> _triggerRandomChallenge() async {
    if (_isRevealing) return;

    final prefs = context.read<PreferencesService>();
    if (prefs.hapticsEnabled) HapticFeedback.heavyImpact();

    setState(() {
      _isShaking = true;
      _isRevealing = true;
      _currentChallenge = null;
    });

    _shakeController.repeat(reverse: true);
    
    // Simulate chaos/loading time
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _shakeController.stop();
    _shakeController.reset();

    if (prefs.hapticsEnabled) HapticFeedback.vibrate();

    setState(() {
      _isShaking = false;
      _currentChallenge = _challenges[Random().nextInt(_challenges.length)];
    });
  }

  void _reset() {
    setState(() {
      _isRevealing = false;
      _currentChallenge = null;
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
          'Random Challenge',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A1050), AppColors.background],
            radius: 1.5,
            center: Alignment.center,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRevealing) ...[
              FadeInDown(
                child: const GradientIconContainer(
                  icon: Icons.bolt_rounded,
                  color: AppColors.neonGreen,
                  size: 100,
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: Text(
                  'SHAKE PHONE',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: AppColors.neonGreen.withAlpha(100), blurRadius: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'or tap the button to trigger chaos',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _triggerRandomChallenge,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.neonGreen, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withAlpha(40),
                          blurRadius: 30,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'RANDOMIZE',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neonGreen,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (_isShaking) ...[
              RotationTransition(
                turns: _shakeAnimation,
                child: const GradientIconContainer(
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.neonPink,
                  size: 120,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'GENERATING CHAOS...',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neonPink,
                  letterSpacing: 4,
                ),
              ),
            ] else if (_currentChallenge != null) ...[
              ZoomIn(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.neonGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withAlpha(30),
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.neonGreen, size: 40),
                      const SizedBox(height: 20),
                      Text(
                        _currentChallenge!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _reset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AGAIN',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
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
}
