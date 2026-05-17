import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/preferences_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<PreferencesService>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
            children: [
              _buildSectionLabel('SOUND'),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      title: 'Sound Effects',
                      icon: LucideIcons.volume2,
                      value: prefs.soundEnabled,
                      color: AppColors.neonCyan,
                      onChanged: (_) => prefs.toggleSound(),
                    ),
                    _Divider(),
                    _SliderTile(
                      title: 'Volume',
                      icon: LucideIcons.volume1,
                      value: prefs.volume,
                      color: AppColors.neonCyan,
                      onChanged: prefs.setVolume,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('FEEDBACK'),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: _SwitchTile(
                  title: 'Haptic Feedback',
                  icon: Icons.vibration_rounded,
                  value: prefs.hapticsEnabled,
                  color: AppColors.neonPink,
                  onChanged: (_) => prefs.toggleHaptics(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('GAME DEFAULTS'),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _StepperTile(
                      title: 'Questions Per Game',
                      icon: LucideIcons.list,
                      value: prefs.questionsPerGame,
                      min: 5,
                      max: 30,
                      step: 5,
                      color: AppColors.primary,
                      onChanged: prefs.setQuestionsPerGame,
                    ),
                    _Divider(),
                    _DropdownTile(
                      title: 'Wheel Style',
                      icon: LucideIcons.circle,
                      value: prefs.wheelStyle,
                      options: const ['Classic', 'Neon', 'Minimal'],
                      color: AppColors.secondary,
                      onChanged: prefs.setWheelStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('DATA'),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: _ActionTile(
                  title: 'Clear All Data',
                  subtitle: 'Removes saved players and packs',
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.dareRed,
                  onTap: () => _showClearDataDialog(context, prefs),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('ABOUT'),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoTile(
                      title: 'Version',
                      value: '1.0.0',
                      icon: LucideIcons.info,
                    ),
                    _Divider(),
                    _InfoTile(
                      title: 'Credits',
                      value: 'Built with ♥ by Antigravity',
                      icon: Icons.code_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white38,
          letterSpacing: 2,
        ),
      ),
    );
  }

  void _showClearDataDialog(
      BuildContext context, PreferencesService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Data?',
          style: GoogleFonts.sora(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete your custom packs and saved players.',
          style: GoogleFonts.sora(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.sora(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              prefs.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared.',
                      style: GoogleFonts.sora()),
                  backgroundColor: AppColors.dareRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.sora(
                  color: AppColors.dareRed,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        color: Colors.white.withAlpha(15),
        indent: 52,
      );
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: color,
        inactiveTrackColor: AppColors.surfaceBright,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        inactiveColor: AppColors.surfaceBright,
        min: 0.0,
        max: 1.0,
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final int step;
  final Color color;
  final ValueChanged<int> onChanged;

  const _StepperTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: value > min
                ? () => onChanged(value - step)
                : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceBright,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value',
              style: GoogleFonts.sora(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          GestureDetector(
            onTap: value < max
                ? () => onChanged(value + step)
                : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceBright,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final List<String> options;
  final Color color;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.options,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.surface,
        style: TextStyle(color: color),
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.arrow_drop_down_rounded, color: color),
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o,
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          color: color, size: 14),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(10)),
        child:
            Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
