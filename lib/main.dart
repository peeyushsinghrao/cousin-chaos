import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';
import 'services/player_manager.dart';
import 'services/pack_manager.dart';
import 'services/preferences_service.dart';
import 'services/impostor_pack_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: const CousinChaosApp(),
    ),
  );
}

class CousinChaosApp extends StatelessWidget {
  const CousinChaosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cousin Chaos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
