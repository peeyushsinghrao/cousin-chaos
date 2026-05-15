import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/constants/modes_data.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';

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
  ChaosEvent? _secondEvent;
  bool _isFlashing = false;
  int _eventCount = 0;
  bool _isDoubleChaos = false;

  final List<ChaosEvent> _events = ModeData.chaosEvents.map((data) {
    ChaosEventType type = ChaosEventType.dare;
    if (data.title == 'SPEED!') {
      type = ChaosEventType.timer;
    } else if (data.title == 'FREEZE!') {
      type = ChaosEventType.freeze;
    } else if (data.title == 'PUNISHMENT!') {
      type = ChaosEventType.punishment;
    } else if (data.title == 'EVERYONE DRINKS!') {
      type = ChaosEventType.everyone;
    } else if (data.title == 'RAPID FIRE!') {
      type = ChaosEventType.rapidFire;
    }
    return ChaosEvent(type, data.title, data.description, data.color);
  }).toList();

  @override
  void initState() {
    super.initState();
    _nextEvent();
  }

  void _nextEvent() async {
    HapticFeedback.vibrate();
    final soundEnabled = context.read<PreferencesService>().soundEnabled;

    setState(() {
      _isFlashing = true;
    });

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) HapticFeedback.selectionClick();
    }

    if (!mounted) return;

    _eventCount++;
    final doDouble = _eventCount % 7 == 0;

    HapticFeedback.heavyImpact();
    SoundService.instance.play(SoundEvent.cardReveal, soundEnabled: soundEnabled);

    setState(() {
      _isFlashing = false;
      _isDoubleChaos = doDouble;
      _currentEvent = _events[_random.nextInt(_events.length)];
      if (doDouble) {
        int secondIdx;
        do {
          secondIdx = _random.nextInt(_events.length);
        } while (_events[secondIdx].title == _currentEvent!.title && _events.length > 1);
        _secondEvent = _events[secondIdx];
      } else {
        _secondEvent = null;
      }
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: _isFlashing ? Colors.black : Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isDoubleChaos && !_isFlashing ? 'DOUBLE CHAOS!' : 'CHAOS MODE',
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

    if (_isDoubleChaos && _secondEvent != null) {
      return _buildDoubleChaosLayout();
    }

    return _buildSingleEventLayout(_currentEvent!);
  }

  Widget _buildSingleEventLayout(ChaosEvent event) {
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
                  child: _buildEventCard(event),
                ),
              ),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDoubleChaosLayout() {
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElasticIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonYellow.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonYellow.withAlpha(120)),
                ),
                child: Text(
                  'DOUBLE CHAOS!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neonYellow,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ElasticIn(
                    duration: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                      child: _buildEventCard(_currentEvent!),
                    ),
                  ),
                ),
                Expanded(
                  child: ElasticIn(
                    duration: const Duration(milliseconds: 900),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
                      child: _buildEventCard(_secondEvent!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildEventCard(ChaosEvent event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: event.color.withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: event.color, size: _isDoubleChaos ? 48 : 80),
          const SizedBox(height: 12),
          Text(
            event.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: _isDoubleChaos ? 28 : 48,
              fontWeight: FontWeight.w900,
              color: event.color,
              letterSpacing: 2,
              shadows: [
                Shadow(color: event.color.withAlpha(100), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: _isDoubleChaos ? 14 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
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
    );
  }
}
