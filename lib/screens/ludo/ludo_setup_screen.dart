import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/ludo_token.dart';
import '../../services/ludo_game_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';
import '../../services/haptic_service.dart';
import 'ludo_board_screen.dart';

class LudoSetupScreen extends StatefulWidget {
  const LudoSetupScreen({super.key});

  @override
  State<LudoSetupScreen> createState() => _LudoSetupScreenState();
}

class _LudoSetupScreenState extends State<LudoSetupScreen> {
  int _playerCount = 2;
  final List<TextEditingController> _nameControllers =
      List.generate(4, (_) => TextEditingController());
  bool _showPersonalities = false;

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFFFEE58),
  ];

  static const List<String> _playerLabels = ['Blue', 'Red', 'Green', 'Yellow'];

  bool get _canStart => List.generate(
        _playerCount,
        (i) => _nameControllers[i].text.trim().isNotEmpty,
      ).every((b) => b);

  void _startGame() {
    final prefs = context.read<PreferencesService>();
    SoundService.instance.play(SoundEvent.gameStart, soundEnabled: prefs.soundEnabled);
    HapticService.instance.trigger(HapticEvent.gameStart, hapticsEnabled: prefs.hapticsEnabled);

    final names = List.generate(
      _playerCount,
      (i) => _nameControllers[i].text.trim(),
    );
    final state = LudoGameService.instance.createGame(names);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LudoBoardScreen(gameState: state)),
    );
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeroSection(),
                      const SizedBox(height: 28),
                      _buildPlayerCountRow(prefs),
                      const SizedBox(height: 24),
                      _buildNameFields(),
                      const SizedBox(height: 20),
                      _buildPersonalitiesInfo(),
                      const SizedBox(height: 28),
                      _buildStartButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Ludo Chaos',
            style: GoogleFonts.anybody(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text('🎲', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonYellow.withAlpha(20),
            AppColors.neonOrange.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonYellow.withAlpha(60)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '13 Chaos Features',
                  style: GoogleFonts.anybody(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neonYellow,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pass the phone · 2–4 players · One winner',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }

  Widget _buildPlayerCountRow(PreferencesService prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of players',
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [2, 3, 4].map((n) {
            final isSelected = _playerCount == n;
            final color = _playerColors[n - 2];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _playerCount = n);
                  HapticService.instance.trigger(
                    HapticEvent.tap, hapticsEnabled: prefs.hapticsEnabled);
                  SoundService.instance.play(
                    SoundEvent.tap, soundEnabled: prefs.soundEnabled);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(30) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withAlpha(50), blurRadius: 10)]
                        : [],
                  ),
                  child: Column(children: [
                    Text(
                      '$n',
                      style: GoogleFonts.anybody(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? color : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'Players',
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        color: isSelected ? color : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Player names',
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _playerCount; i++) ...[
          _buildNameField(i),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildNameField(int i) {
    final color = _playerColors[i];
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
            border: Border.all(color: color.withAlpha(120)),
          ),
          child: Center(
            child: Text(
              _playerLabels[i][0],
              style: GoogleFonts.anybody(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _nameControllers[i],
            maxLength: 15,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.sora(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '${_playerLabels[i]} player name',
              hintStyle: GoogleFonts.sora(
                color: AppColors.textMuted, fontSize: 13,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withAlpha(60)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withAlpha(40)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalitiesInfo() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showPersonalities = !_showPersonalities),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Token personalities are randomly assigned at game start',
                  style: GoogleFonts.sora(
                    color: AppColors.textSecondary, fontSize: 12,
                  ),
                ),
              ),
              Icon(
                _showPersonalities
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppColors.textMuted, size: 20,
              ),
            ]),
          ),
        ),
        if (_showPersonalities) ...[
          const SizedBox(height: 8),
          for (final p in TokenPersonality.values)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(children: [
                Text(
                  LudoToken.personalityEmoji(p),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LudoToken.personalityName(p),
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      LudoToken.personalityDesc(p),
                      style: GoogleFonts.sora(
                        color: AppColors.textMuted, fontSize: 11,
                      ),
                    ),
                  ],
                )),
              ]),
            ),
        ],
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canStart ? _startGame : null,
        icon: const Icon(Icons.casino_rounded),
        label: Text(
          'Start Game',
          style: GoogleFonts.sora(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonYellow,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: _canStart ? 8 : 0,
          shadowColor: AppColors.neonYellow.withAlpha(80),
        ),
      ),
    );
  }
}
