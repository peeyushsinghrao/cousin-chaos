import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';

class FreezeModeScreen extends StatefulWidget {
  const FreezeModeScreen({super.key});

  @override
  State<FreezeModeScreen> createState() => _FreezeModeScreenState();
}

class _FreezeModeScreenState extends State<FreezeModeScreen> {
  final Random _random = Random();
  bool _isPlaying = false;
  bool _isFrozen = false;
  bool _showPenalty = false;
  
  Timer? _hiddenTimer;
  Timer? _freezeTimer;
  int _freezeTimeLeft = 0;

  @override
  void dispose() {
    _hiddenTimer?.cancel();
    _freezeTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isFrozen = false;
      _showPenalty = false;
    });

    // Random wait between 5 to 15 seconds before freezing
    final waitTime = _random.nextInt(11) + 5;
    _hiddenTimer = Timer(Duration(seconds: waitTime), _triggerFreeze);
  }

  void _triggerFreeze() {
    HapticFeedback.vibrate();
    
    // Flash effect simulator
    for(int i=0; i<5; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if(mounted) HapticFeedback.heavyImpact();
      });
    }

    setState(() {
      _isFrozen = true;
      _freezeTimeLeft = _random.nextInt(21) + 10; // 10 to 30 seconds
    });

    _freezeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_freezeTimeLeft > 0) {
        setState(() => _freezeTimeLeft--);
      } else {
        timer.cancel();
        _showPenaltyPopup();
      }
    });
  }

  void _showPenaltyPopup() {
    setState(() {
      _isFrozen = false;
      _showPenalty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFrozen) {
      return _buildFrozenScreen();
    }

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
          'FREEZE MODE',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.truthBlue,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.truthBlue.withAlpha(40), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_showPenalty) _buildPenaltyPopup(),
            if (!_isPlaying && !_showPenalty) ...[
              const Icon(Icons.ac_unit_rounded, color: AppColors.truthBlue, size: 100),
              const SizedBox(height: 32),
              Text(
                'Place phone where everyone can see.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'When the screen flashes FREEZE,\neveryone must freeze physically.\nIf you move, you lose!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _startGame();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.truthBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.truthBlue.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'START',
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
            if (_isPlaying && !_isFrozen)
              Pulse(
                infinite: true,
                child: Column(
                  children: [
                    const Icon(Icons.music_note_rounded, color: AppColors.truthBlue, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Act normal... for now.',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrozenScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Flash(
          infinite: true,
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.ac_unit_rounded, color: AppColors.truthBlueDark, size: 120),
              Text(
                'FREEZE!',
                style: GoogleFonts.poppins(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dareRed,
                  letterSpacing: 4,
                ),
              ),
              Text(
                '$_freezeTimeLeft',
                style: GoogleFonts.poppins(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                'SECONDS LEFT',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltyPopup() {
    return ZoomIn(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.dareRed, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.dareRed, size: 64),
            const SizedBox(height: 24),
            Text(
              'DID ANYONE MOVE?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If you moved during the freeze,\nyou have to take a penalty shot\nor do 10 pushups!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                setState(() => _showPenalty = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.dareRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'DONE',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
