import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/player_manager.dart';
import 'services/pack_manager.dart';
import 'services/preferences_service.dart';
import 'services/impostor_pack_manager.dart';
import 'services/theme_pack_service.dart';
import 'services/supabase_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SupabaseService.initialize();
  final seenOnboarding = await hasSeenOnboarding();
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerManager()),
        ChangeNotifierProvider(create: (_) => PackManager()),
        ChangeNotifierProvider(create: (_) => PreferencesService()),
        ChangeNotifierProvider(create: (_) => ImpostorPackManager()),
        ChangeNotifierProvider(create: (_) => ThemePackService()),
      ],
      child: CousinChaosApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class CousinChaosApp extends StatelessWidget {
  final bool seenOnboarding;
  const CousinChaosApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cousin Chaos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      color: AppColors.background,
      home: seenOnboarding ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
