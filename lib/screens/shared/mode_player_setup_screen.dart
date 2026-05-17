import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/player_manager.dart';

/// Shared player setup screen for WYR and NHIE modes
class ModePlayerSetupScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData icon;
  final Widget Function(BuildContext) onStart;

  const ModePlayerSetupScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.icon,
    required this.onStart,
  });

  @override
  State<ModePlayerSetupScreen> createState() => _ModePlayerSetupScreenState();
}

class _ModePlayerSetupScreenState extends State<ModePlayerSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final pm = context.watch<PlayerManager>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Text(widget.title.toUpperCase(), style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: widget.themeColor, letterSpacing: 2,
                    )),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Hero card
                      FadeInDown(child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [widget.themeColor.withAlpha(25), AppColors.surface],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: widget.themeColor.withAlpha(60)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: widget.themeColor.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(widget.icon, color: widget.themeColor, size: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(widget.title, style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                            )),
                            const SizedBox(height: 4),
                            Text(widget.subtitle, textAlign: TextAlign.center, style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.textMuted,
                            )),
                          ],
                        ),
                      )),
                      const SizedBox(height: 28),
                      // Players header
                      FadeInLeft(child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PLAYERS (${pm.playerCount})', style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.textMuted, letterSpacing: 2,
                          )),
                          if (pm.playerCount < 10)
                            GestureDetector(
                              onTap: () { HapticFeedback.lightImpact(); pm.addPlayer(); },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.themeColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: widget.themeColor.withAlpha(60)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, color: widget.themeColor, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Add', style: GoogleFonts.poppins(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: widget.themeColor,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )),
                      const SizedBox(height: 12),
                      // Player list
                      ...pm.players.asMap().entries.map((entry) {
                        final i = entry.key;
                        final player = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 50 * i),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceBright),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [widget.themeColor, widget.themeColor.withAlpha(150)]),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                                  ))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: player.name),
                                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Player ${i + 1}',
                                      hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                                    ),
                                    onChanged: (v) => pm.updatePlayerName(player.id, v),
                                  ),
                                ),
                                if (pm.playerCount > 2)
                                  IconButton(
                                    onPressed: () { HapticFeedback.lightImpact(); pm.removePlayer(player.id); },
                                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.dareRed, size: 20),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Start button
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    Navigator.push(context, PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => widget.onStart(context),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                    ));
                  },
                  child: Container(
                    width: double.infinity, height: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [widget.themeColor, widget.themeColor.withAlpha(180)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: widget.themeColor.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8),
                      )],
                    ),
                    child: Center(child: Text('START GAME 🎮', style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2,
                    ))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
