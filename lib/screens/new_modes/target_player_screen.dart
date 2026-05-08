import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';
import '../../widgets/dynamic_timer_widget.dart';

class TargetPlayerScreen extends StatefulWidget {
  const TargetPlayerScreen({super.key});

  @override
  State<TargetPlayerScreen> createState() => _TargetPlayerScreenState();
}

class _TargetPlayerScreenState extends State<TargetPlayerScreen> {
  final Random _random = Random();
  bool _isSpinning = false;
  String? _selectedPlayer;
  String? _currentCategory;
  String? _currentPrompt;
  
  final StreamController<int> _selectedController = StreamController<int>.broadcast();
  int _lastSelectedIndex = -1;

  final List<String> _categories = ['Funny', 'Savage', 'Friendly', 'Extreme'];
  
  final Map<String, List<String>> _prompts = {
    'Funny': [
      'What is their most embarrassing habit?',
      'If they were an animal, what would they be?',
      'Dare them to do a 15 second interpretive dance.'
    ],
    'Savage': [
      'Roast their fashion sense in 3 words.',
      'What is the cringiest thing they have ever said?',
      'Name one thing they think they are good at, but actually aren\\'t.'
    ],
    'Friendly': [
      'What is your favorite memory with them?',
      'Give them a genuine compliment.',
      'What is their best personality trait?'
    ],
    'Extreme': [
      'Dare them to send a risky text to the 5th contact on their phone.',
      'Ask them to reveal their biggest regret.',
      'Dare them to eat a spoonful of hot sauce or mustard.'
    ]
  };

  final List<String> _everyonePrompts = [
    'Everyone dance for 30 seconds!',
    'Everyone tell an embarrassing story.',
    'Everyone do 10 jumping jacks!',
    'Everyone swap phones for 1 minute.',
    'Everyone freeze for 20 seconds!',
    'Everyone speak in an accent for 2 minutes!',
  ];

  @override
  void dispose() {
    _selectedController.close();
    super.dispose();
  }

  void _spinWheel(List<String> items) {
    if (_isSpinning) return;
    
    HapticFeedback.heavyImpact();
    setState(() {
      _isSpinning = true;
      _selectedPlayer = null;
      _currentPrompt = null;
      _currentCategory = null;
    });

    _lastSelectedIndex = _random.nextInt(items.length);
    _selectedController.add(_lastSelectedIndex);
  }

  void _onSpinComplete(List<String> items) {
    HapticFeedback.vibrate();
    
    setState(() {
      _isSpinning = false;
      _selectedPlayer = items[_lastSelectedIndex];
      
      if (_selectedPlayer == 'Everyone') {
        _currentCategory = 'Group Challenge';
        _currentPrompt = _everyonePrompts[_random.nextInt(_everyonePrompts.length)];
      } else {
        _currentCategory = _categories[_random.nextInt(_categories.length)];
        final list = _prompts[_currentCategory!]!;
        _currentPrompt = list[_random.nextInt(list.length)];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayerManager>().players;
    
    if (players.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Add players to play this mode.', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    
    // Add "Everyone" option
    final List<String> wheelItems = [...players.map((p) => p.name), 'Everyone'];

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
          'SPIN THE WHEEL',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              _selectedPlayer == 'Everyone' ? AppColors.dareRed.withAlpha(50) : AppColors.neonPink.withAlpha(40), 
              AppColors.background
            ],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // The Wheel
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FortuneWheel(
                  selected: _selectedController.stream,
                  animateFirst: false,
                  physics: CircularPanPhysics(
                    duration: const Duration(seconds: 1),
                    curve: Curves.decelerate,
                  ),
                  onFling: () {
                    _spinWheel(wheelItems);
                  },
                  onAnimationEnd: () {
                    _onSpinComplete(wheelItems);
                  },
                  indicators: const <FortuneIndicator>[
                    FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: TriangleIndicator(
                        color: AppColors.neonYellow,
                      ),
                    ),
                  ],
                  items: [
                    for (int i = 0; i < wheelItems.length; i++) ...<FortuneItem>{
                      FortuneItem(
                        child: Text(
                          wheelItems[i],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: FortuneItemStyle(
                          color: wheelItems[i] == 'Everyone' 
                              ? AppColors.dareRed 
                              : (i % 2 == 0 ? AppColors.neonPink : AppColors.surfaceLight),
                          borderColor: AppColors.surfaceBright,
                          borderWidth: 2,
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (!_isSpinning && _currentPrompt != null)
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _selectedPlayer == 'Everyone' ? AppColors.dareRed : AppColors.neonPink, 
                              width: 2
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_selectedPlayer == 'Everyone' ? AppColors.dareRed : AppColors.neonPink).withAlpha(40),
                                blurRadius: 40,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                _selectedPlayer == 'Everyone' ? 'CHAOS MODE' : 'TARGET ACQUIRED',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedPlayer!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: _selectedPlayer == 'Everyone' ? AppColors.dareRed : AppColors.neonPink,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (_selectedPlayer == 'Everyone' ? AppColors.dareRed : AppColors.neonPink).withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentCategory!.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _selectedPlayer == 'Everyone' ? AppColors.dareRed : AppColors.neonPink,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _currentPrompt!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                              
                              // Automatically add dynamic timer if prompt has time
                              DynamicTimerWidget(text: _currentPrompt!),
                            ],
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 24),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      child: GestureDetector(
                        onTap: _isSpinning ? null : () => _spinWheel(wheelItems),
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _isSpinning ? AppColors.surfaceLight : AppColors.neonGreen,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _isSpinning ? [] : [
                              BoxShadow(
                                color: AppColors.neonGreen.withAlpha(60),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'SPIN THE WHEEL',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _isSpinning ? AppColors.textMuted : Colors.black,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
