import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';

enum ChaosEventType { dare, timer, freeze, punishment, everyone, rapidFire }

class ChaosEvent {
  final ChaosEventType type;
  final String title;
  final String description;
  final Color color;

  ChaosEvent(this.type, this.title, this.description, this.color);
}

class ChaosModeScreen extends StatefulWidget {
  const ChaosModeScreen({super.key});

  @override
  State<ChaosModeScreen> createState() => _ChaosModeScreenState();
}

class _ChaosModeScreenState extends State<ChaosModeScreen> {
  final Random _random = Random();
  ChaosEvent? _currentEvent;
  bool _isFlashing = false;

  final List<ChaosEvent> _events = [
    ChaosEvent(ChaosEventType.dare, 'DARE!', 'Do a backflip or drink!', AppColors.dareRed),
    ChaosEvent(ChaosEventType.timer, 'SPEED!', 'Name 5 animals in 5 seconds. GO!', AppColors.neonYellow),
    ChaosEvent(ChaosEventType.freeze, 'FREEZE!', 'Nobody move for 10 seconds. First to move loses.', AppColors.truthBlue),
    ChaosEvent(ChaosEventType.punishment, 'PUNISHMENT!', 'The person holding the phone takes a penalty.', AppColors.neonPink),
    ChaosEvent(ChaosEventType.everyone, 'EVERYONE DRINKS!', 'Cheers to chaos!', AppColors.neonGreen),
    ChaosEvent(ChaosEventType.rapidFire, 'RAPID FIRE!', 'Ask the person to your left 3 questions fast.', AppColors.neonOrange),
  ];

  @override
  void initState() {
    super.initState();
    _nextEvent();
  }

  void _nextEvent() async {
    HapticFeedback.vibrate();
    
    setState(() {
      _isFlashing = true;
    });

    for(int i=0; i<8; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if(mounted) HapticFeedback.selectionClick();
    }

    if (!mounted) return;
    
    HapticFeedback.heavyImpact();
    setState(() {
      _isFlashing = false;
      _currentEvent = _events[_random.nextInt(_events.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isFlashing 
        ? Colors.white 
        : (_currentEvent?.color ?? AppColors.background);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _isFlashing ? Colors.black : Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHAOS MODE',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _isFlashing ? Colors.black : Colors.white,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: _isFlashing ? _buildFlashingScreen() : _buildEventScreen(),
    );
  }

  Widget _buildFlashingScreen() {
    return Center(
      child: Flash(
        infinite: true,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.cyclone_rounded, color: Colors.black, size: 150),
      ),
    );
  }

  Widget _buildEventScreen() {
    if (_currentEvent == null) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.black.withAlpha(80), Colors.black.withAlpha(200)],
          radius: 1.5,
          center: Alignment.center,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ElasticIn(
                duration: const Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: _currentEvent!.color, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        _currentEvent!.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: _currentEvent!.color,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(color: _currentEvent!.color.withAlpha(100), blurRadius: 20),
                          ]
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _currentEvent!.color.withAlpha(50)),
                        ),
                        child: Text(
                          _currentEvent!.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: GestureDetector(
              onTap: _nextEvent,
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(40),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'NEXT CHAOS',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
    );
  }
}
