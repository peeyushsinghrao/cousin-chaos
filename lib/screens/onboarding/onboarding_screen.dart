import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

const String _kOnboardingComplete = 'onboarding_complete';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingComplete) ?? false;
}

Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingComplete, true);
}

class _StepData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final Color gradientTop;
  final Color gradientBottom;

  const _StepData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.gradientTop,
    required this.gradientBottom,
  });
}

const List<_StepData> _steps = [
  _StepData(
    title: 'THE CHAOS\nAWAITS',
    subtitle: 'Party games for groups',
    icon: Icons.local_fire_department_rounded,
    iconColor: AppColors.primary,
    glowColor: Color(0x66DDB7FF),
    gradientTop: Color(0xFF3A1C61),
    gradientBottom: AppColors.background,
  ),
  _StepData(
    title: 'YOUR CREW,\nYOUR RULES',
    subtitle: 'Add players & customize',
    icon: Icons.group_rounded,
    iconColor: AppColors.secondary,
    glowColor: Color(0x6692DBFF),
    gradientTop: Color(0xFF14496B),
    gradientBottom: AppColors.background,
  ),
  _StepData(
    title: 'READY\nTO PLAY',
    subtitle: '6 game modes await',
    icon: Icons.sports_esports_rounded,
    iconColor: AppColors.accent,
    glowColor: Color(0x66FF5167),
    gradientTop: Color(0xFF661931),
    gradientBottom: Color(0xFF3A1C61),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Cubic(0.16, 1, 0.3, 1),
    ));

    _contentController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_currentStep < _steps.length - 1) {
      _contentController.reset();
      setState(() => _currentStep++);
      _contentController.forward();
    } else {
      _finish();
    }
  }

  void _finish() async {
    await markOnboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [step.gradientTop, step.gradientBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Step counter — top right
              Positioned(
                top: 20,
                right: 24,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${_currentStep + 1} / ${_steps.length}',
                    key: ValueKey(_currentStep),
                    style: GoogleFonts.sora(
                      color: AppColors.textPrimary.withAlpha(153),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),

              // Main layout
              Column(
                children: [
                  // Icon area — upper half
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radial glow blob
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeInOut,
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: step.glowColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: step.glowColor,
                                    blurRadius: 80,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),

                            // Floating icon
                            AnimatedBuilder(
                              animation: _floatAnim,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(0, _floatAnim.value),
                                child: child,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                switchInCurve: Curves.easeOut,
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  step.icon,
                                  key: ValueKey(_currentStep),
                                  size: 110,
                                  color: step.iconColor,
                                  shadows: [
                                    Shadow(
                                      color: step.iconColor.withAlpha(204),
                                      blurRadius: 30,
                                    ),
                                    Shadow(
                                      color: step.iconColor.withAlpha(102),
                                      blurRadius: 60,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Text content — lower half
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                step.title,
                                style: GoogleFonts.anybody(
                                  color: AppColors.textPrimary,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                step.subtitle,
                                style: GoogleFonts.sora(
                                  color: AppColors.textPrimary.withAlpha(179),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: _OnboardingButton(
                      isLastStep: isLastStep,
                      onTap: _advance,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingButton extends StatefulWidget {
  final bool isLastStep;
  final VoidCallback onTap;

  const _OnboardingButton({required this.isLastStep, required this.onTap});

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(31),
            gradient: widget.isLastStep
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: widget.isLastStep
                ? null
                : Colors.white.withAlpha(18),
            border: widget.isLastStep
                ? null
                : Border.all(
                    color: Colors.white.withAlpha(46),
                    width: 1,
                  ),
            boxShadow: widget.isLastStep
                ? AppTheme.neonGlow(AppColors.accent, blurRadius: 24)
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey(widget.isLastStep),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isLastStep ? 'UNLEASH THE CHAOS' : 'Continue',
                    style: GoogleFonts.sora(
                      color: widget.isLastStep
                          ? AppColors.background
                          : AppColors.textPrimary,
                      fontSize: widget.isLastStep ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: widget.isLastStep ? 1.5 : 0,
                    ),
                  ),
                  if (!widget.isLastStep) ...[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
