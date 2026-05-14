import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../new_modes/impostor_category_selection_screen.dart';

class ImpostorModeSetupScreen extends StatefulWidget {
  const ImpostorModeSetupScreen({super.key});

  @override
  State<ImpostorModeSetupScreen> createState() =>
      _ImpostorModeSetupScreenState();
}

class _ImpostorModeSetupScreenState extends State<ImpostorModeSetupScreen> {
  int _playerCount = 5;
  int _impostorCount = 1;
  bool _timeLimitEnabled = true;
  int _timeLimitSeconds = 300;

  void _adjustPlayerCount(int delta) {
    final nextCount = _playerCount + delta;
    if (nextCount < 3 || nextCount > 20) return;
    setState(() {
      _playerCount = nextCount;
      if (_impostorCount >= _playerCount) {
        _impostorCount = _playerCount - 1;
      }
    });
  }

  void _adjustImpostorCount(int delta) {
    final nextCount = _impostorCount + delta;
    if (nextCount < 1 || nextCount >= _playerCount) return;
    setState(() {
      _impostorCount = nextCount;
    });
  }

  void _adjustTimeLimit(int delta) {
    setState(() {
      _timeLimitSeconds += delta;
      if (_timeLimitSeconds < 60) _timeLimitSeconds = 60;
      if (_timeLimitSeconds > 3600) _timeLimitSeconds = 3600;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImpostorCategorySelectionScreen(
          playerCount: _playerCount,
          impostorCount: _impostorCount,
          timeLimitEnabled: _timeLimitEnabled,
          timeLimitSeconds: _timeLimitSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Header with back and settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'IMPOSTOR MODE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anybody(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find who doesn\'t know the secret word',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Two Main Cards: Players & Impostors
                  Row(
                    children: [
                      Expanded(
                        child: _buildSetupCard(
                          icon: Icons.people,
                          label: 'HOW MANY\nPLAYERS?',
                          value: _playerCount.toString(),
                          onAdd: () => _adjustPlayerCount(1),
                          onRemove: () => _adjustPlayerCount(-1),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSetupCard(
                          icon: Icons.person_remove,
                          label: 'HOW MANY\nIMPOSTORS?',
                          value: _impostorCount.toString(),
                          onAdd: () => _adjustImpostorCount(1),
                          onRemove: () => _adjustImpostorCount(-1),
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Time Limit Card
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: AppColors.tertiary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIME LIMIT',
                                style: Theme.of(context)
                                    .textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.tertiary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_timeLimitSeconds),
                                style: Theme.of(context)
                                    .textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _timeLimitEnabled,
                          onChanged: (value) {
                            setState(() => _timeLimitEnabled = value);
                          },
                          activeColor: AppColors.tertiary,
                          inactiveThumbColor:
                              AppColors.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  if (_timeLimitEnabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.tertiary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _adjustTimeLimit(-30),
                            child: const Text('- 30s'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.tertiary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _adjustTimeLimit(30),
                            child: const Text('+ 30s'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 40),
                  // Game Mode Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GAME MODE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.neonPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.text_fields,
                                color: AppColors.neonPink,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WORD GAME',
                                    style: Theme.of(context)
                                        .textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Find who doesn\'t know the secret word',
                                    style: Theme.of(context)
                                        .textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.neonPink
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: AppColors.neonPink,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Start Game Button
                  GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'START GAME',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required Color color,
  }) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(Icons.remove, color: color, size: 16),
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.add, color: color, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
