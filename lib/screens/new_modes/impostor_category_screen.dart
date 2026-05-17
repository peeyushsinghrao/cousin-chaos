import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/impostor_data.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../shared/category_grid_screen.dart';
import 'impostor_settings_screen.dart';

class ImpostorCategoryScreen extends StatelessWidget {
  const ImpostorCategoryScreen({super.key});

  static const _categoryIcons = <String, IconData>{
    'GAMING': LucideIcons.gamepad2,
    'TIKTOK MEMES': LucideIcons.laugh,
    'FOODS': LucideIcons.tag,
    'BRANDS & SNEAKERS': LucideIcons.package,
    'MOVIES & SHOWS': LucideIcons.theater,
    'SCHOOL LIFE': LucideIcons.list,
    'COUNTRIES & CITIES': LucideIcons.share2,
    'FAMILY SCENARIOS': LucideIcons.users,
    'MUSIC': LucideIcons.sparkles,
    'SUPERHEROES & VILLAINS': LucideIcons.star,
    'SPORTS': LucideIcons.trophy,
    'SOCIAL MEDIA': LucideIcons.heart,
    'SCIENCE': LucideIcons.brain,
    'RANDOM OBJECTS': LucideIcons.dices,
    'REACTIONS & EMOTIONS': LucideIcons.meh,
    'LATE NIGHT VIBES': LucideIcons.moon,
    'CHAOS CLASSICS': LucideIcons.zap,
    'ADULTING DISASTERS': LucideIcons.alertTriangle,
    'NIGHTS OUT': LucideIcons.flame,
    'RELATIONSHIP CHAOS': LucideIcons.heart,
  };

  @override
  Widget build(BuildContext context) {
    final rawCats = ImpostorData.categories.keys.toList();
    final categories = rawCats.map((k) => CategoryItem(
          id: k,
          label: _formatLabel(k),
          icon: _categoryIcons[k] ?? LucideIcons.tag,
          badgeCount: ImpostorData.categories[k]?.length,
        )).toList();

    return CategoryGridScreen(
      modeName: 'Impostor',
      modeColor: AppColors.tertiary,
      step: 1,
      totalSteps: 2,
      title: 'Pick a Category',
      categories: categories,
      multiSelect: false,
      minSelect: 1,
      onConfirm: (selected) {
        final category = selected.first;
        Navigator.push(
          context,
          slideUpRoute(ImpostorSettingsScreen(preSelectedCategory: category)),
        );
      },
    );
  }

  String _formatLabel(String key) {
    return key
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
