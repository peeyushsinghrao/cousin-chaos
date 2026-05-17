import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/navigation/page_transitions.dart';
import '../../services/pack_manager.dart';
import 'create_pack_screen.dart';

class CustomPacksScreen extends StatelessWidget {
  const CustomPacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packManager = context.watch<PackManager>();
    final packs = packManager.customPacks;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Custom Packs',
            style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: packs.isEmpty
                  ? Center(
                      child: Text('No custom packs yet. Create one to get started.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 16)),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: packs.length,
                      itemBuilder: (context, index) {
                        final pack = packs[index];
                        return GestureDetector(
                          onLongPress: () => _showPackOptions(context, packManager, pack.id),
                          child: GlassCard(
                            borderRadius: 24,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pack.emoji, style: const TextStyle(fontSize: 32)),
                                const SizedBox(height: 12),
                                Text(pack.title,
                                    style: GoogleFonts.sora(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    )),
                                const SizedBox(height: 8),
                                Text('${pack.prompts.length} items',
                                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12)),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.star, color: AppColors.secondary, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Custom', style: GoogleFonts.plusJakartaSans(color: AppColors.secondary)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, slideUpRoute(const CreatePackScreen()));
              },
              child: GlassCard(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('CREATE NEW PACK',
                        style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPackOptions(BuildContext context, PackManager packManager, String packId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.white),
                title: Text('Delete', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                onTap: () {
                  packManager.removeCustomPack(packId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: Colors.white),
                title: Text('Duplicate', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: Text('Edit', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
