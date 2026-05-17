import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../services/pack_manager.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../shared/category_grid_screen.dart';
import 'nhie_game_screen.dart';

class NhieSetupScreen extends StatelessWidget {
  const NhieSetupScreen({super.key});

  static const _color = AppColors.neonOrange;

  static const _categories = [
    CategoryItem(
      id: 'party_starter',
      label: 'Party Starter',
      icon: LucideIcons.laugh,
      description: 'Classic confessions',
    ),
    CategoryItem(
      id: 'mild_but_wild',
      label: 'Mild But Wild',
      icon: LucideIcons.flame,
      description: 'Getting spicy',
    ),
    CategoryItem(
      id: 'family_night',
      label: 'Family Night',
      icon: LucideIcons.home,
      description: 'Keep it clean',
    ),
    CategoryItem(
      id: 'spice_it_up',
      label: 'Spice It Up',
      icon: LucideIcons.zap,
      description: 'Adults only',
    ),
    CategoryItem(
      id: 'girls_night',
      label: "Girls Night",
      icon: LucideIcons.heart,
      description: 'Girly secrets',
    ),
    CategoryItem(
      id: 'guys_unleashed',
      label: 'Guys Unleashed',
      icon: LucideIcons.star,
      description: 'Lads confess',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryGridScreen(
      modeName: 'Never Have I Ever',
      modeColor: _color,
      step: 1,
      totalSteps: 2,
      title: 'Choose Packs',
      categories: _categories,
      multiSelect: true,
      minSelect: 1,
      initialSelected: const ['party_starter'],
      onConfirm: (selected) {
        DisclaimerDialog.show(context, () {
          final pm = context.read<PackManager>();
          pm.clearSelection();
          for (final id in selected) {
            pm.togglePackSelection(id);
          }
          Navigator.push(context, slideUpRoute(const NeverHaveIEverScreen()));
        });
      },
    );
  }
}
