import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/wyr_data.dart';
import '../../services/player_manager.dart';
import '../../services/api_service.dart';
import '../../services/pack_manager.dart';


class WouldYouRatherScreen extends StatefulWidget {
  const WouldYouRatherScreen({super.key});

  @override
  State<WouldYouRatherScreen> createState() => _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends State<WouldYouRatherScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _currentPlayerIndex = 0;
  String? _selectedOption; // 'A' or 'B'
  bool _showReaction = false;
  late AnimationController _pulseController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _bounceController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _loadQuestions();
  }

  void _loadQuestions() {
    final pm = context.read<PackManager>();
    final selectedPacks = pm.selectedPackIds;
    var filtered = WyrData.questions;
    if (selectedPacks.isNotEmpty) {
      filtered = WyrData.questions.where((q) => selectedPacks.contains(q['category'])).toList();
      if (filtered.isEmpty) filtered = WyrData.questions;
    }
    _questions.addAll(List.from(filtered)..shuffle(Random()));
    _fetchApiQuestion();
  }

  Future<void> _fetchApiQuestion() async {
    final prompt = await ApiService.fetchWouldYouRather();
    if (prompt != null && mounted) {
      final text = prompt.text;
      if (text.toLowerCase().contains(' or ')) {
        final parts = text.split(RegExp(r'\s+or\s+', caseSensitive: false));
        if (parts.length >= 2) {
          setState(() {
            _questions.add({
              'optionA': parts[0].replaceFirst(RegExp(r'^Would you rather\s*', caseSensitive: false), '').trim(),
              'optionB': parts.sublist(1).join(' or ').replaceFirst('?', '').trim(),
              'category': 'api',
            });
          });
        }
      }
    }
  }

  Map<String, dynamic> get _currentQuestion => _questions[_currentIndex % _questions.length];

  void _selectOption(String option) {
    if (_selectedOption != null) return;
    HapticFeedback.heavyImpact();
    _bounceController.forward(from: 0);
    setState(() {
      _selectedOption = option;
      _showReaction = true;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    final pm = context.read<PlayerManager>();
    setState(() {
      _currentIndex++;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % pm.players.length;
      _selectedOption = null;
      _showReaction = false;
    });
    if (_currentIndex % 5 == 0) _fetchApiQuestion();
    if (_currentIndex >= _questions.length - 3) {
      final pm = context.read<PackManager>();
      final selectedPacks = pm.selectedPackIds;
      var filtered = WyrData.questions;
      if (selectedPacks.isNotEmpty) {
        filtered = WyrData.questions.where((q) => selectedPacks.contains(q['category'])).toList();
        if (filtered.isEmpty) filtered = WyrData.questions;
      }
      _questions.addAll(List.from(filtered)..shuffle(Random()));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<PlayerManager>();
    final player = pm.players[_currentPlayerIndex % pm.players.length];
    final q = _currentQuestion;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0518), Color(0xFF12082A), Color(0xFF0A0518)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(player.name),
              const SizedBox(height: 8),
              _buildPlayerIndicator(pm, player.name),
              const SizedBox(height: 16),
              FadeIn(child: _buildQuestionLabel()),
              const SizedBox(height: 12),
              Expanded(child: _buildOptionCards(q)),
              if (_selectedOption == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('TAP YOUR CHOICE', style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.textMuted, letterSpacing: 3,
                  )),
                ),
              if (_showReaction) _buildReaction(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String playerName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          Text('WOULD YOU RATHER', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: AppColors.truthBlue, letterSpacing: 2,
          )),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _nextQuestion();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator(PlayerManager pm, String currentName) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pm.players.length,
        itemBuilder: (context, i) {
          final p = pm.players[i];
          final isActive = p.name == currentName;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.truthBlue.withAlpha(30) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.truthBlue : AppColors.surfaceBright, width: isActive ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(p.name, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.truthBlue : AppColors.textMuted,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionLabel() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.truthBlue, AppColors.neonCyan],
      ).createShader(bounds),
      child: Text('Would You Rather...', style: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
      )),
    );
  }

  Widget _buildOptionCards(Map<String, dynamic> q) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(child: _buildOptionCard(q['optionA'] ?? '', 'A',
            const [Color(0xFF00C6FF), Color(0xFF0072FF)], Icons.looks_one_rounded)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.primaryNeon.withAlpha(
                    (100 + 80 * _pulseController.value).toInt()), width: 2),
                  boxShadow: [BoxShadow(
                    color: AppColors.primaryNeon.withAlpha((40 * _pulseController.value).toInt()),
                    blurRadius: 20,
                  )],
                ),
                child: Center(child: Text('OR', style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryNeon,
                ))),
              ),
            ),
          ),
          Expanded(child: _buildOptionCard(q['optionB'] ?? '', 'B',
            const [Color(0xFFFF2D55), Color(0xFFD50032)], Icons.looks_two_rounded)),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String text, String option, List<Color> colors, IconData icon) {
    final isSelected = _selectedOption == option;
    final isOther = _selectedOption != null && !isSelected;

    return GestureDetector(
      onTap: () => _selectOption(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isOther
              ? [Colors.grey.shade900, Colors.grey.shade800]
              : [colors[0].withAlpha(isSelected ? 255 : 40), colors[1].withAlpha(isSelected ? 255 : 25)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isOther ? Colors.grey.shade700 : colors[0].withAlpha(isSelected ? 255 : 100),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(
            color: colors[0].withAlpha(80), blurRadius: 30, spreadRadius: -5,
          )] : [],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(top: -30, right: -30, child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.white.withAlpha(30), Colors.transparent])),
              )),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                  ],
                  Icon(icon, color: isOther ? Colors.grey : (isSelected ? Colors.white : colors[0]), size: 28),
                  const SizedBox(height: 12),
                  Text(text, textAlign: TextAlign.center, style: GoogleFonts.poppins(
                    fontSize: isSelected ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: isOther ? Colors.grey : Colors.white,
                    height: 1.3,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaction() {
    final reactions = ['🔥', '😱', '💀', '😂', '🤯', '👀', '💣', '⚡'];
    reactions.shuffle();
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(reactions.first, style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Leave Game?', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
      content: Text('Are you sure you want to quit?', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('Stay', style: GoogleFonts.poppins(color: AppColors.textMuted))),
        TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
          child: Text('Leave', style: GoogleFonts.poppins(color: AppColors.dareRed))),
      ],
    ));
  }
}
