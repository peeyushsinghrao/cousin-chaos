import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/ludo_player.dart';
import '../../../core/models/ludo_token.dart';
import '../../../core/theme/app_colors.dart';

class SabotageSheet extends StatefulWidget {
  final List<LudoPlayer> players;
  final int currentPlayerIndex;
  final void Function(int targetPlayerIndex, String type, LudoToken? token) onApply;

  const SabotageSheet({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.onApply,
  });

  @override
  State<SabotageSheet> createState() => _SabotageSheetState();
}

class _SabotageSheetState extends State<SabotageSheet> {
  String? _selectedType;
  int? _selectedPlayerIndex;
  LudoToken? _selectedToken;

  static const List<Color> _playerColors = [
    Color(0xFF4FC3F7),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFFFEE58),
  ];

  final _types = [
    ('freeze', '🥶', 'Freeze', 'Target skips their next turn'),
    ('sendBack5', '↩️', 'Send Back 5', 'Move one of their tokens back 5 spaces'),
    ('blockHome', '🚧', 'Block Home Entry', 'They cannot enter their home column for 2 turns'),
  ];

  @override
  Widget build(BuildContext context) {
    final opponents = widget.players
        .where((p) => p.index != widget.currentPlayerIndex)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '⚡ Sabotage',
                style: GoogleFonts.anybody(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dareRed,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Choose type:', style: GoogleFonts.sora(
              color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 10),
            for (final (type, emoji, label, desc) in _types)
              _buildTypeCard(type, emoji, label, desc),
            const SizedBox(height: 16),
            if (_selectedType != null) ...[
              Text('Choose target:', style: GoogleFonts.sora(
                color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              for (final p in opponents)
                _buildPlayerCard(p),
            ],
            if (_selectedType != null &&
                _selectedPlayerIndex != null &&
                _selectedType == 'sendBack5') ...[
              const SizedBox(height: 16),
              Text('Choose token:', style: GoogleFonts.sora(
                color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: widget.players[_selectedPlayerIndex!].tokens
                    .where((t) => t.isOnBoard &&
                        t.pathPosition < 52 &&
                        t.personality != TokenPersonality.armored)
                    .map((t) => _buildTokenChip(t))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canConfirm() ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dareRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('Confirm Sabotage',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canConfirm() {
    if (_selectedType == null || _selectedPlayerIndex == null) return false;
    if (_selectedType == 'sendBack5' && _selectedToken == null) return false;
    return true;
  }

  void _confirm() {
    widget.onApply(_selectedPlayerIndex!, _selectedType!, _selectedToken);
    Navigator.pop(context);
  }

  Widget _buildTypeCard(String type, String emoji, String label, String desc) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedToken = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dareRed.withAlpha(25)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.dareRed : AppColors.outlineVariant,
          ),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.sora(
                fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13,
              )),
              Text(desc, style: GoogleFonts.sora(
                color: AppColors.textMuted, fontSize: 11,
              )),
            ],
          )),
          if (isSelected) Icon(Icons.check_circle_rounded, color: AppColors.dareRed, size: 20),
        ]),
      ),
    );
  }

  Widget _buildPlayerCard(LudoPlayer p) {
    final isSelected = _selectedPlayerIndex == p.index;
    final color = _playerColors[p.index];
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPlayerIndex = p.index;
        _selectedToken = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.outlineVariant),
        ),
        child: Row(children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Text(p.name, style: GoogleFonts.sora(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14,
          )),
          const Spacer(),
          Text('Score: ${p.score}', style: GoogleFonts.sora(
            color: AppColors.textMuted, fontSize: 12,
          )),
        ]),
      ),
    );
  }

  Widget _buildTokenChip(LudoToken t) {
    final isSelected = _selectedToken?.id == t.id;
    final color = _playerColors[t.playerIndex];
    return GestureDetector(
      onTap: () => setState(() => _selectedToken = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(40) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.outlineVariant),
        ),
        child: Text(
          'Token ${t.tokenIndex + 1} ${LudoToken.personalityEmoji(t.personality)}',
          style: GoogleFonts.sora(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
