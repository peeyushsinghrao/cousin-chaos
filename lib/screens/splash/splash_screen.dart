import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadingProgress = Tween<double>(begin: 0, end: 0.67).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.15),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Branding Section
                  _buildBrandingSection(),

                  const SizedBox(height: 60),

                  // Glass Hero Image Area
                  _buildHeroImage(),

                  const SizedBox(height: 60),

                  // Action / Loading Section
                  _buildActionSection(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      children: [
        Text(
          'COUSIN\nCHAOS',
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 64,
            height: 1.1,
            shadows: [
              Shadow(
                color: AppColors.primary.withOpacity(0.8),
                blurRadius: 20,
              ),
              Shadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'THE ULTIMATE PARTY DISRUPTOR',
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      borderRadius: 40,
      child: Icon(
        Icons.sports_esports,
        size: 80,
        color: AppColors.primary,
        shadows: [
          Shadow(
            color: AppColors.primary.withOpacity(0.8),
            blurRadius: 20,
          ),
          Shadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        // Loading Indicator
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: AnimatedBuilder(
              animation: _loadingProgress,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _loadingProgress.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: AppTheme.neonGlow(AppColors.secondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // TAP TO START Button
        NeonButton(
          label: 'TAP TO START',
          onTap: _navigateToHome,
          gradient: AppTheme.primaryGradient,
        ),

        const SizedBox(height: 16),

        // Status Label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Synchronizing Chaos...',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
