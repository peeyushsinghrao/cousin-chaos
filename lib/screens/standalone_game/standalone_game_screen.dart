import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../models/pack.dart';
import '../../services/api_service.dart';
import '../../services/pack_manager.dart';
import '../../widgets/dynamic_timer_widget.dart';

import '../../core/constants/trivia_data.dart';

enum StandaloneGameType { wyr, nhie, trivia }

class StandaloneGameScreen extends StatefulWidget {
  final StandaloneGameType type;
  
  const StandaloneGameScreen({super.key, required this.type});

  @override
  State<StandaloneGameScreen> createState() => _StandaloneGameScreenState();
}

class _StandaloneGameScreenState extends State<StandaloneGameScreen> {
  GameCardPrompt? _currentCard;
  bool _isLoading = true;

  // Local Trivia Database
  final List<Map<String, dynamic>> _triviaDb = TriviaData.questions;

  @override
  void initState() {
    super.initState();
    _loadNextCard();
  }

  Future<void> _loadNextCard() async {
    setState(() {
      _isLoading = true;
      _currentCard = null;
    });

    GameCardPrompt? nextCard;

    if (widget.type == StandaloneGameType.wyr) {
      nextCard = await ApiService.fetchWouldYouRather();
      nextCard ??= GameCardPrompt(id: 'fallback', text: 'Would you rather have super strength or super speed?', type: 'wyr');
    } else if (widget.type == StandaloneGameType.nhie) {
      nextCard = await ApiService.fetchNeverHaveIEver();
      nextCard ??= GameCardPrompt(id: 'fallback', text: 'Never have I ever lied to get out of trouble.', type: 'nhie');
    } else if (widget.type == StandaloneGameType.trivia) {
      // Simulate network delay for premium feel
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      final pm = context.read<PackManager>();
      final selectedPacks = pm.selectedPackIds;
      var filtered = TriviaData.questions;
      if (selectedPacks.isNotEmpty) {
        filtered = TriviaData.questions.where((q) => selectedPacks.contains(q['category'])).toList();
        if (filtered.isEmpty) filtered = TriviaData.questions;
      }
      
      final db = List.from(filtered)..shuffle();
      final t = db.first;
      nextCard = GameCardPrompt(
        id: 'trivia_${DateTime.now().millisecondsSinceEpoch}',
        text: '${t['q']}|${t['a']}', // Hack to store Q and A
        type: 'trivia',
      );
    }

    if (mounted) {
      setState(() {
        _currentCard = nextCard;
        _isLoading = false;
      });
    }
  }

  String get _title {
    switch (widget.type) {
      case StandaloneGameType.wyr: return 'Would You Rather';
      case StandaloneGameType.nhie: return 'Never Have I Ever';
      case StandaloneGameType.trivia: return 'Trivia Battle';
    }
  }

  Color get _themeColor {
    switch (widget.type) {
      case StandaloneGameType.wyr: return AppColors.truthBlue;
      case StandaloneGameType.nhie: return AppColors.neonPink;
      case StandaloneGameType.trivia: return AppColors.neonYellow;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case StandaloneGameType.wyr: return Icons.help_outline_rounded;
      case StandaloneGameType.nhie: return Icons.front_hand_rounded;
      case StandaloneGameType.trivia: return Icons.psychology_rounded;
    }
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
          _title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _themeColor,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [_themeColor.withAlpha(40), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isLoading 
                  ? _buildLoading() 
                  : _buildCard(),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: _themeColor),
        const SizedBox(height: 20),
        Text(
          'Drawing next card...',
          style: GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    if (_currentCard == null) return const SizedBox();

    String questionText = _currentCard!.text;
    String? answerText;

    if (widget.type == StandaloneGameType.trivia) {
      final parts = questionText.split('|');
      questionText = parts[0];
      if (parts.length > 1) answerText = parts[1];
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _themeColor.withAlpha(80), width: 2),
          boxShadow: [
            BoxShadow(
              color: _themeColor.withAlpha(30),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _themeColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _themeColor, size: 40),
              ),
              const SizedBox(height: 32),
              Text(
                questionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              DynamicTimerWidget(text: questionText),
              if (answerText != null) ...[
                const SizedBox(height: 40),
                _TriviaAnswerReveal(answerText: answerText, themeColor: _themeColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _loadNextCard();
        },
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: _themeColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _themeColor.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'NEXT CARD',
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
    );
  }
}

class _TriviaAnswerReveal extends StatefulWidget {
  final String answerText;
  final Color themeColor;

  const _TriviaAnswerReveal({required this.answerText, required this.themeColor});

  @override
  State<_TriviaAnswerReveal> createState() => _TriviaAnswerRevealState();
}

class _TriviaAnswerRevealState extends State<_TriviaAnswerReveal> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (!_revealed) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _revealed = true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBright),
          ),
          child: Text(
            'TAP TO REVEAL ANSWER',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    return FadeIn(
      child: Column(
        children: [
          Text(
            'ANSWER:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: widget.themeColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.answerText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
