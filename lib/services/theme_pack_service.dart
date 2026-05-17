import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

class AppThemePack {
  final String id;
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final List<Color> backgroundGradient;
  final List<Color> ambientOrb1;
  final List<Color> ambientOrb2;

  const AppThemePack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.backgroundGradient,
    required this.ambientOrb1,
    required this.ambientOrb2,
  });
}

class ThemePackService extends ChangeNotifier {
  static const String _key = 'active_theme_pack';
  String _activeId = 'default';

  String get activeId => _activeId;
  AppThemePack get active => packs.firstWhere((p) => p.id == _activeId, orElse: () => packs.first);

  ThemePackService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _activeId = prefs.getString(_key) ?? 'default';
    notifyListeners();
  }

  Future<void> setTheme(String id) async {
    _activeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
    notifyListeners();
  }

  static const List<AppThemePack> packs = [
    AppThemePack(
      id: 'default',
      name: 'Neon Night',
      emoji: '🌃',
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      accent: AppColors.dareRed,
      background: Color(0xFF0A0512),
      surface: Color(0xFF17111F),
      backgroundGradient: [Color(0xFF08041A), Color(0xFF0E0624), Color(0xFF08041A)],
      ambientOrb1: [Color(0x19DDB7FF), Colors.transparent],
      ambientOrb2: [Color(0x1292DBFF), Colors.transparent],
    ),
    AppThemePack(
      id: 'halloween',
      name: 'Halloween',
      emoji: '🎃',
      primary: Color(0xFFFF7D00),
      secondary: Color(0xFF9B59B6),
      accent: Color(0xFFFF2020),
      background: Color(0xFF0A0200),
      surface: Color(0xFF1A0A02),
      backgroundGradient: [Color(0xFF0A0200), Color(0xFF1A0800), Color(0xFF0A0200)],
      ambientOrb1: [Color(0x33FF7D00), Colors.transparent],
      ambientOrb2: [Color(0x229B59B6), Colors.transparent],
    ),
    AppThemePack(
      id: 'beach',
      name: 'Beach Party',
      emoji: '🏖️',
      primary: Color(0xFF00B4D8),
      secondary: Color(0xFFFF9E00),
      accent: Color(0xFFFF4B6E),
      background: Color(0xFF001A2C),
      surface: Color(0xFF002A3D),
      backgroundGradient: [Color(0xFF001A2C), Color(0xFF003A50), Color(0xFF001A2C)],
      ambientOrb1: [Color(0x2200B4D8), Colors.transparent],
      ambientOrb2: [Color(0x22FF9E00), Colors.transparent],
    ),
    AppThemePack(
      id: 'space',
      name: 'Deep Space',
      emoji: '🚀',
      primary: Color(0xFF7DF9FF),
      secondary: Color(0xFFBD00FF),
      accent: Color(0xFFFF3CAC),
      background: Color(0xFF000008),
      surface: Color(0xFF0A0A1E),
      backgroundGradient: [Color(0xFF000008), Color(0xFF06062A), Color(0xFF000008)],
      ambientOrb1: [Color(0x1E7DF9FF), Colors.transparent],
      ambientOrb2: [Color(0x22BD00FF), Colors.transparent],
    ),
    AppThemePack(
      id: 'forest',
      name: 'Enchanted Forest',
      emoji: '🌿',
      primary: Color(0xFF39FF14),
      secondary: Color(0xFF00E5CC),
      accent: Color(0xFFFFD700),
      background: Color(0xFF010D00),
      surface: Color(0xFF051A04),
      backgroundGradient: [Color(0xFF010D00), Color(0xFF071C05), Color(0xFF010D00)],
      ambientOrb1: [Color(0x2239FF14), Colors.transparent],
      ambientOrb2: [Color(0x1800E5CC), Colors.transparent],
    ),
  ];
}
