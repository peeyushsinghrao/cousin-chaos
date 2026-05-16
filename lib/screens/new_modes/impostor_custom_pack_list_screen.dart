import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/page_transitions.dart';
import '../../models/impostor_player.dart';
import '../../services/impostor_pack_manager.dart';
import 'impostor_custom_pack_editor_screen.dart';
import 'impostor_game_screen.dart';

class ImpostorCustomPackListScreen extends StatelessWidget {
  final List<ImpostorPlayer> players;
  final bool timeLimitEnabled;
  final int? timeLimitSeconds;
  final int impostorCount;

  const ImpostorCustomPackListScreen({
    super.key,
    required this.players,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
    required this.impostorCount,
  });

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ImpostorPackManager>();
    final packs = manager.customPacks;

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
          'CUSTOM PACKS',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                slideUpRoute(const ImpostorCustomPackEditorScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBright),
              ),
              child: Text(
                'Create custom word packs for Impostor Mode. Save as many packs as you want, then tap one to start the game.',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: packs.isEmpty
                  ? Center(
                      child: Text(
                        'No custom packs yet. Use the + button to add your first one.',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: packs.length,
                      itemBuilder: (context, index) {
                        final pack = packs[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBright),
                          ),
                          child: ListTile(
                            title: Text(
                              pack.title,
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${pack.words.length} words · Created ${pack.createdAt.month}/${pack.createdAt.day}/${pack.createdAt.year}',
                              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.neonPink),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      slideUpRoute(ImpostorCustomPackEditorScreen(pack: pack)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      slideUpRoute(ImpostorGameScreen(
                                        category: 'CUSTOM PACK',
                                        players: players,
                                        impostorCount: impostorCount,
                                        timeLimitEnabled: timeLimitEnabled,
                                        timeLimitSeconds: timeLimitSeconds,
                                        customWords: pack.words,
                                      )),
                                    );
                                  },
                                ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonPink,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            slideUpRoute(const ImpostorCustomPackEditorScreen()),
          );
        },
      ),
    );
  }
}
