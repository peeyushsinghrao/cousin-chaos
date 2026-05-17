import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/impostor_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/page_transitions.dart';
import 'impostor_players_screen.dart';

class ImpostorSettingsScreen extends StatefulWidget {
  const ImpostorSettingsScreen({super.key});

  @override
  State<ImpostorSettingsScreen> createState() => _ImpostorSettingsScreenState();
}

class _ImpostorSettingsScreenState extends State<ImpostorSettingsScreen> {
  bool _timeLimitEnabled = false;
  int _timeLimitSeconds = 180;
  String _selectedCategory = 'GAMING';
  bool _showCategoryToImpostor = false;
  bool _showHintToImpostor = false;

  final List<int> _timeLimitOptions = [60, 90, 120, 180, 240, 300, 420, 600];

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0 ? '${m}m' : '${m}m ${r}s';
  }

  void _showTimeLimitSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Time Limit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          ..._timeLimitOptions.map((s) => ListTile(
            title: Text(_formatSeconds(s), style: GoogleFonts.poppins(color: Colors.white)),
            trailing: _timeLimitSeconds == s ? const Icon(Icons.check_rounded, color: AppColors.neonPink) : null,
            onTap: () {
              setState(() { _timeLimitSeconds = s; _timeLimitEnabled = true; });
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCategorySheet() {
    final cats = ImpostorData.categories.keys.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Category', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: cats.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(cats[i], style: GoogleFonts.poppins(color: Colors.white)),
                  trailing: _selectedCategory == cats[i] ? const Icon(Icons.check_rounded, color: AppColors.neonPink) : null,
                  onTap: () {
                    setState(() => _selectedCategory = cats[i]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      slideUpRoute(ImpostorPlayersScreen(
        category: _selectedCategory,
        timeLimitEnabled: _timeLimitEnabled,
        timeLimitSeconds: _timeLimitSeconds,
        showCategoryToImpostor: _showCategoryToImpostor,
        showHintToImpostor: _showHintToImpostor,
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
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGlass, width: 1),
            ),
            child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          'GAME SETTINGS',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.neonPink, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.neonPink.withAlpha(25), AppColors.background],
            radius: 1.0,
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionLabel('Content'),
                  const SizedBox(height: 10),
                  _buildTappableTile(
                    icon: Icons.category_rounded,
                    label: 'Category',
                    value: _selectedCategory,
                    onTap: _showCategorySheet,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Rules'),
                  const SizedBox(height: 10),
                  _buildToggleTile(
                    icon: Icons.timer_rounded,
                    label: 'Time Limit',
                    value: _timeLimitEnabled,
                    subtitle: _timeLimitEnabled ? _formatSeconds(_timeLimitSeconds) : 'Off',
                    onToggle: (v) => setState(() => _timeLimitEnabled = v),
                    onSubtitleTap: _showTimeLimitSheet,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    icon: Icons.visibility_rounded,
                    label: 'Show Category to Impostor',
                    value: _showCategoryToImpostor,
                    onToggle: (v) => setState(() => _showCategoryToImpostor = v),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    icon: Icons.lightbulb_rounded,
                    label: 'Show Hint to Impostor',
                    value: _showHintToImpostor,
                    onToggle: (v) => setState(() => _showHintToImpostor = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _onNext,
                  child: Text(
                    'NEXT — PLAYERS',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTappableTile({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBright),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonPink, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
            Text(value, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({required IconData icon, required String label, required bool value, required Function(bool) onToggle, String? subtitle, VoidCallback? onSubtitleTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBright),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neonPink, size: 22),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
              Switch(
                value: value,
                onChanged: onToggle,
                activeTrackColor: AppColors.neonPink,
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.surfaceBright,
              ),
            ],
          ),
          if (subtitle != null && value)
            GestureDetector(
              onTap: onSubtitleTap,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(subtitle, style: GoogleFonts.poppins(color: AppColors.neonPink, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_rounded, color: AppColors.neonPink, size: 14),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
