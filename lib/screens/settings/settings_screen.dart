import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/preferences_service.dart';
import '../../core/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Radial gradient at top
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    AppColors.primaryContainer.withAlpha(80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Consumer<PreferencesService>(
            builder: (context, prefs, child) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 56),
                  // Header
                  Row(
                    children: [
                      Text(
                        'SETTINGS',
                        style: GoogleFonts.sora(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(13),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(26)),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // PROFILE CARD
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 30,
                        spreadRadius: -10,
                      ),
                    ],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.secondaryContainer, AppColors.primaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CC',
                                  style: GoogleFonts.sora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cousin Chaos Player',
                                  style: GoogleFonts.sora(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Level 14 Instigator',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Colors.white10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Games', '6', AppColors.secondaryContainer),
                            _buildStatItem('Players', '12', AppColors.primary),
                            _buildStatItem('CP', '1,240', AppColors.gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // GAMEPLAY FEEL
                  _buildSectionLabel('GAMEPLAY FEEL'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 24,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.volume_up_rounded,
                          iconColor: AppColors.secondaryContainer,
                          title: 'Sound Effects',
                          subtitle: 'Immersive audio & stings',
                          trailing: Switch(
                            value: prefs.soundEnabled,
                            onChanged: (_) => prefs.toggleSound(),
                            activeColor: AppColors.secondaryContainer,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 64),
                        _buildSettingRow(
                          icon: Icons.vibration_rounded,
                          iconColor: AppColors.primary,
                          title: 'Haptic Feedback',
                          subtitle: 'Device vibrations',
                          trailing: Switch(
                            value: prefs.hapticsEnabled,
                            onChanged: (_) => prefs.toggleHaptics(),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // CONTENT
                  _buildSectionLabel('CONTENT'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 24,
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.layers_rounded,
                          iconColor: AppColors.gold,
                          title: 'Custom Packs',
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          onTap: () {}, // Not specified in task, but placeholder for navigation
                        ),
                        const Divider(color: Colors.white10, height: 1, indent: 64),
                        _buildSettingRow(
                          icon: Icons.history_rounded,
                          iconColor: Colors.white,
                          title: 'Game History',
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // DANGER ZONE
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.tertiaryContainer, size: 16),
                      const SizedBox(width: 8),
                      _buildSectionLabel('DANGER ZONE', color: AppColors.tertiaryContainer),
                    ],
                  ),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 24,
                    blur: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withAlpha(13),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tertiaryContainer.withAlpha(77)),
                      ),
                      child: _buildSettingRow(
                        icon: Icons.delete_outline_rounded,
                        iconColor: AppColors.tertiaryContainer,
                        title: 'Clear All Data',
                        subtitle: 'Reset everything to zero',
                        titleColor: AppColors.tertiaryContainer,
                        trailing: TextButton(
                          onPressed: () => _showClearDataDialog(context, prefs),
                          child: Text(
                            'DELETE',
                            style: GoogleFonts.sora(
                              color: AppColors.tertiaryContainer,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Made with 🔥 for chaotic families',
                      style: GoogleFonts.sora(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom nav space
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.sora(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, PreferencesService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear Data?',
          style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete your custom packs and saved players. Are you sure?',
          style: GoogleFonts.sora(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.sora(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              prefs.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared.', style: GoogleFonts.sora()),
                  backgroundColor: AppColors.tertiaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Delete', style: GoogleFonts.sora(color: AppColors.tertiaryContainer, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
