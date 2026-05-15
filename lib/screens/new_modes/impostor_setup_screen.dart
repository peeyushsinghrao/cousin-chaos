import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/impostor_data.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../models/impostor_player.dart';
import '../../screens/new_modes/impostor_custom_pack_list_screen.dart';
import 'impostor_game_screen.dart';

class ImpostorSetupScreen extends StatefulWidget {
  final int playerCount;
  final int impostorCount;
  final bool timeLimitEnabled;
  final int? timeLimitSeconds;

  const ImpostorSetupScreen({
    super.key,
    required this.playerCount,
    required this.impostorCount,
    this.timeLimitEnabled = true,
    this.timeLimitSeconds,
  });

  @override
  State<ImpostorSetupScreen> createState() => _ImpostorSetupScreenState();
}

class _ImpostorSetupScreenState extends State<ImpostorSetupScreen> {
  late final List<ImpostorPlayer> _players;
  final List<String> _categories = ['Custom Pack', ...ImpostorData.categories.keys.toList()];

  @override
  void initState() {
    super.initState();
    _players = List.generate(
      widget.playerCount,
      (index) => ImpostorPlayer(id: 'player_${index + 1}', name: 'Player ${index + 1}'),
    );
  }

  void _openCategory(String category) {
    HapticFeedback.lightImpact();

    if (category == 'Custom Pack') {
      Navigator.push(
        context,
        slideUpRoute(ImpostorCustomPackListScreen(
          players: _players,
          impostorCount: widget.impostorCount,
          timeLimitEnabled: widget.timeLimitEnabled,
          timeLimitSeconds: widget.timeLimitSeconds,
        )),
      );
      return;
    }

    Navigator.push(
      context,
      slideUpRoute(ImpostorGameScreen(
        category: category,
        players: _players,
        impostorCount: widget.impostorCount,
        timeLimitEnabled: widget.timeLimitEnabled,
        timeLimitSeconds: widget.timeLimitSeconds,
      )),
    );
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
          'SELECT CATEGORY',
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
            colors: [AppColors.neonPink.withAlpha(30), AppColors.background],
            radius: 1.2,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Choose the theme for your game:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isCustom = category == 'Custom Pack';

                  return GestureDetector(
                    onTap: () => _openCategory(category),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.neonPink.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCustom ? Icons.folder_open : Icons.label,
                            color: AppColors.neonPink,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isCustom
                                      ? 'Manage saved custom word packs.'
                                      : '${ImpostorData.categories[category]?.length ?? 0} words',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonPink, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
