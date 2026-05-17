import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/preferences_service.dart';
import '../../services/theme_pack_service.dart';
import 'theme_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesService>(
      builder: (context, prefs, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.sora(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Customize your experience',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    children: [
                      _SectionHeader(label: 'Sound', icon: LucideIcons.volume2, color: AppColors.neonCyan),
                      _SettingsGroup(
                        children: [
                          _SwitchRow(
                            title: 'Sound Effects',
                            subtitle: 'Game sounds and music',
                            icon: LucideIcons.volume2,
                            color: AppColors.neonCyan,
                            value: prefs.soundEnabled,
                            onChanged: (_) => prefs.toggleSound(),
                          ),
                          _GroupDivider(),
                          _SliderRow(
                            title: 'Volume',
                            icon: LucideIcons.volume1,
                            color: AppColors.neonCyan,
                            value: prefs.volume,
                            onChanged: prefs.setVolume,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(label: 'Haptics', icon: Icons.vibration_rounded, color: AppColors.neonPink),
                      _SettingsGroup(
                        children: [
                          _SwitchRow(
                            title: 'Haptic Feedback',
                            subtitle: 'Vibrations on interactions',
                            icon: Icons.vibration_rounded,
                            color: AppColors.neonPink,
                            value: prefs.hapticsEnabled,
                            onChanged: (_) => prefs.toggleHaptics(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(label: 'Game', icon: LucideIcons.gamepad2, color: AppColors.primary),
                      _SettingsGroup(
                        children: [
                          _StepperRow(
                            title: 'Questions Per Game',
                            subtitle: 'How many rounds per session',
                            icon: LucideIcons.list,
                            color: AppColors.primary,
                            value: prefs.questionsPerGame,
                            min: 5,
                            max: 30,
                            step: 5,
                            onChanged: prefs.setQuestionsPerGame,
                          ),
                          _GroupDivider(),
                          _DropdownRow(
                            title: 'Wheel Style',
                            subtitle: 'Visual theme for the spin wheel',
                            icon: LucideIcons.circle,
                            color: AppColors.secondary,
                            value: prefs.wheelStyle,
                            options: const ['Classic', 'Neon', 'Minimal'],
                            onChanged: prefs.setWheelStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(label: 'Appearance', icon: LucideIcons.palette, color: AppColors.primary),
                      Consumer<ThemePackService>(
                        builder: (ctx, themeService, _) => _SettingsGroup(
                          children: [
                            _ActionRow(
                              title: 'Theme Pack',
                              subtitle: '${themeService.active.emoji} ${themeService.active.name}',
                              icon: LucideIcons.palette,
                              color: AppColors.primary,
                              onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ThemePickerScreen())),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(label: 'Data', icon: LucideIcons.trash, color: AppColors.dareRed),
                      _SettingsGroup(
                        children: [
                          _ActionRow(
                            title: 'Clear All Data',
                            subtitle: 'Remove saved players and packs',
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.dareRed,
                            onTap: () => _showClearDialog(context, prefs),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(label: 'About', icon: LucideIcons.info, color: Colors.white38),
                      _SettingsGroup(
                        children: [
                          _InfoRow(title: 'Version', value: '1.0.0', icon: LucideIcons.tag),
                          _GroupDivider(),
                          _InfoRow(
                            title: 'Built by',
                            value: 'Antigravity ♥',
                            icon: Icons.code_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, PreferencesService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Clear Data?',
            style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete your custom packs and saved players.',
          style: GoogleFonts.sora(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.sora(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              prefs.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared.', style: GoogleFonts.sora()),
                  backgroundColor: AppColors.dareRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Delete',
                style: GoogleFonts.sora(color: AppColors.dareRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Row(
        children: [
          Icon(icon, color: color.withAlpha(200), size: 13),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color.withAlpha(180),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF120E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Column(children: children),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.white.withAlpha(10), indent: 52);
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.sora(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.sora(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color.withAlpha(180),
            activeColor: Colors.white,
            inactiveTrackColor: Colors.white.withAlpha(15),
            inactiveThumbColor: Colors.white38,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: GoogleFonts.sora(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: Colors.white.withAlpha(15),
                thumbColor: color,
                overlayColor: color.withAlpha(30),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.sora(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.sora(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                onTap: value > min ? () => onChanged(value - step) : null,
                color: color,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$value',
                  style: GoogleFonts.sora(color: color, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              _StepBtn(
                icon: Icons.add_rounded,
                onTap: value < max ? () => onChanged(value + step) : null,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _StepBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(22) : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? color.withAlpha(50) : Colors.transparent),
        ),
        child: Icon(icon, color: enabled ? color : Colors.white24, size: 16),
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.sora(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.sora(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF1A1428),
            style: GoogleFonts.sora(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.expand_more_rounded, color: color.withAlpha(180), size: 18),
            items: options
                .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o, style: GoogleFonts.sora(color: Colors.white, fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.sora(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle,
                      style: GoogleFonts.sora(color: Colors.white30, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withAlpha(120), size: 13),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoRow({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white38, size: 17),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.sora(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
