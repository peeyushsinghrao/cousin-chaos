import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../services/pack_manager.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../shared/category_grid_screen.dart';
import 'wyr_game_screen.dart';

class WyrSetupScreen extends StatelessWidget {
  const WyrSetupScreen({super.key});

  static const _color = AppColors.neonYellow;

  static const _categories = [
    CategoryItem(
      id: 'party_starter',
      label: 'Party Starter',
      icon: LucideIcons.laugh,
      description: 'Fun for everyone',
    ),
    CategoryItem(
      id: 'mild_but_wild',
      label: 'Mild But Wild',
      icon: LucideIcons.flame,
      description: 'Getting interesting',
    ),
    CategoryItem(
      id: 'family_night',
      label: 'Family Night',
      icon: LucideIcons.home,
      description: 'All ages welcome',
    ),
    CategoryItem(
      id: 'spice_it_up',
      label: 'Spice It Up',
      icon: LucideIcons.zap,
      description: 'Adults only',
    ),
    CategoryItem(
      id: 'girls_night',
      label: 'Girls Night',
      icon: LucideIcons.heart,
      description: 'Girly chaos',
    ),
    CategoryItem(
      id: 'guys_unleashed',
      label: 'Guys Unleashed',
      icon: LucideIcons.star,
      description: 'Lads on tour',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryGridScreen(
      modeName: 'Would You Rather',
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
          Navigator.push(context, slideUpRoute(const WouldYouRatherScreen()));
        });
      },
    );
  }
}
