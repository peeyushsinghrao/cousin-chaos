import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/page_transitions.dart';
import '../../services/pack_manager.dart';
import '../../models/pack.dart';
import '../../core/widgets/gradient_icon.dart';
import 'player_setup_screen.dart';
import 'custom_pack_screen.dart';

class PackSelectionScreen extends StatelessWidget {
  final Widget Function(BuildContext)? onNext;

  const PackSelectionScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      FadeInDown(
                        child: Row(
                          children: [
                            const GradientIconContainer(
                              icon: Icons.theater_comedy_rounded,
                              color: AppColors.truthBlue,
                              size: 44,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'What are you\nplaying?',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Select one or more packs to play',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<PackManager>(
                        builder: (context, packManager, _) {
                          final packs = packManager.allPacks;
                          return Column(
                            children: [
                              for (int i = 0; i < packs.length; i++)
                                FadeInUp(
                                  delay: Duration(milliseconds: 60 * i),
                                  duration: const Duration(milliseconds: 400),
                                  child: _buildPackCard(
                                    context,
                                    packs[i],
                                    packManager.isSelected(packs[i].id),
                                    () {
                                      HapticFeedback.lightImpact();
                                      packManager.togglePackSelection(packs[i].id);
                                    },
                                  ),
                                ),
                              // Custom Pack Button
                              FadeInUp(
                                delay: Duration(milliseconds: 60 * packs.length),
                                child: _buildCustomPackButton(context),
                              ),
                              const SizedBox(height: 100),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            'STEP 1 OF 3',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Map<String, dynamic> _getIconForPack(String id, String emoji) {
    switch (id) {
      case 'party_starter': return {'icon': Icons.celebration_rounded, 'color': AppColors.neonPink};
      case 'mild_but_wild': return {'icon': Icons.local_fire_department_rounded, 'color': AppColors.neonOrange};
      case 'family_night': return {'icon': Icons.family_restroom_rounded, 'color': AppColors.truthBlue};
      case 'spice_it_up': return {'icon': Icons.whatshot_rounded, 'color': AppColors.dareRed};
      case 'couples_time': return {'icon': Icons.favorite_rounded, 'color': AppColors.neonPink};
      case 'insane_party': return {'icon': Icons.bolt_rounded, 'color': AppColors.neonYellow};
      case 'dirty_wild': return {'icon': Icons.nightlife_rounded, 'color': AppColors.primaryNeon};
      case 'girls_night': return {'icon': Icons.girl_rounded, 'color': AppColors.neonPink};
      case 'guys_unleashed': return {'icon': Icons.sports_martial_arts_rounded, 'color': AppColors.neonCyan};
      default: return {'icon': Icons.star_rounded, 'color': AppColors.primaryNeon};
    }
  }

  Widget _buildPackCard(BuildContext context, Pack pack, bool isSelected, VoidCallback onTap) {
    final borderColor = isSelected ? AppColors.primaryNeon : AppColors.surfaceBright;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryNeon.withAlpha(20) 
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryNeon.withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon
            GradientIconContainer(
              icon: _getIconForPack(pack.id, pack.emoji)['icon'] as IconData,
              color: _getIconForPack(pack.id, pack.emoji)['color'] as Color,
              size: 50,
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          pack.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (pack.is18Plus) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dareRed.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '18+',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dareRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pack.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.quiz_rounded, size: 12, color: AppColors.textMuted.withAlpha(150)),
                      const SizedBox(width: 4),
                      Text(
                        '${pack.prompts.length} Prompts',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNeon : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNeon : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          slideUpRoute(const CustomPackScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBright, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceBright,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: AppColors.primaryNeon, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Pack',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNeon,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Create your own Truth & Dare game.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<PackManager>(
      builder: (context, packManager, _) {
        final count = packManager.selectedPackIds.length;
        final isActive = count > 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.surfaceBright, width: 1)),
          ),
          child: GestureDetector(
            onTap: isActive
                ? () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (_, __, ___) => onNext != null ? onNext!(context) : const PlayerSetupScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 58,
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryNeon.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  isActive ? 'Start ($count ${count == 1 ? 'pack' : 'packs'} selected)' : 'Select a pack to start',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
