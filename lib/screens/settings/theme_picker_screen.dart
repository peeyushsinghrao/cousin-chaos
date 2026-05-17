import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/theme_pack_service.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemePackService>(
      builder: (context, svc, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [svc.active.background, svc.active.background.withBlue(40), svc.active.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Themes', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('Pick your vibe', style: GoogleFonts.sora(fontSize: 12, color: Colors.white38)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: ThemePackService.packs.length,
                      itemBuilder: (_, i) => _buildThemeTile(context, ThemePackService.packs[i], svc),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context, AppThemePack pack, ThemePackService svc) {
    final isActive = svc.activeId == pack.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          svc.setTheme(pack.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? pack.primary.withAlpha(15) : Colors.white.withAlpha(6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? pack.primary.withAlpha(150) : Colors.white.withAlpha(18),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [BoxShadow(color: pack.primary.withAlpha(40), blurRadius: 20, spreadRadius: -2)] : [],
          ),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [pack.primary, pack.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: pack.primary.withAlpha(60), blurRadius: 12)],
                ),
                child: Center(child: Text(pack.emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pack.name, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ColorDot(color: pack.primary),
                        const SizedBox(width: 6),
                        _ColorDot(color: pack.secondary),
                        const SizedBox(width: 6),
                        _ColorDot(color: pack.accent),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: pack.primary),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                )
              else
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14, height: 14,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
