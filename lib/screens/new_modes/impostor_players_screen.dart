import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'impostor_setup_screen.dart';

class ImpostorPlayersScreen extends StatefulWidget {
  const ImpostorPlayersScreen({super.key});

  @override
  State<ImpostorPlayersScreen> createState() => _ImpostorPlayersScreenState();
}

class _ImpostorPlayersScreenState extends State<ImpostorPlayersScreen> {
  int _playerCount = 5;
  int _impostorCount = 1;
  bool _timeLimitEnabled = true;
  int _timeLimitSeconds = 300;

  void _adjustPlayerCount(int delta) {
    final nextCount = _playerCount + delta;
    if (nextCount < 3 || nextCount > 20) return;
    setState(() {
      _playerCount = nextCount;
      _impostorCount = _recommendedImpostorCount(_playerCount);
    });
  }

  void _adjustImpostorCount(int delta) {
    final nextCount = _impostorCount + delta;
    if (nextCount < 1 || nextCount >= _playerCount) return;
    setState(() {
      _impostorCount = nextCount;
    });
  }

  int _recommendedImpostorCount(int playerCount) {
    if (playerCount <= 6) return 1;
    if (playerCount <= 9) return 2;
    if (playerCount <= 12) return 3;
    if (playerCount <= 15) return 4;
    if (playerCount <= 18) return 5;
    return 6;
  }

  void _openSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImpostorSetupScreen(
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'IMPOSTOR SETUP',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Party Setup',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose how many players are joining, how many impostors will be hidden, and whether the timer is on.',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            _buildCountCard(
              label: 'Players',
              value: _playerCount.toString(),
              icon: Icons.group,
              onDecrease: () => _adjustPlayerCount(-1),
              onIncrease: () => _adjustPlayerCount(1),
            ),
            const SizedBox(height: 16),
            _buildCountCard(
              label: 'Impostors',
              value: _impostorCount.toString(),
              icon: Icons.local_fire_department,
              onDecrease: () => _adjustImpostorCount(-1),
              onIncrease: () => _adjustImpostorCount(1),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBright),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: AppColors.neonPink),
                      const SizedBox(width: 12),
                      Text(
                        'Discussion Timer',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _timeLimitEnabled ? '${_timeLimitSeconds ~/ 60} minutes' : 'Timer disabled',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                      Switch(
                        value: _timeLimitEnabled,
                        activeColor: AppColors.neonPink,
                        onChanged: (value) => setState(() => _timeLimitEnabled = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _openSetup,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceBright),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Category',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to pick the themed word category or use your own custom pack.',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonPink, size: 20),
                  ],
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _openSetup,
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.neonPink,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPink.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'CONTINUE TO CATEGORY',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBright),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.neonPink.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.neonPink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Row(
            children: [
              _buildSmallControl(Icons.remove, onDecrease),
              const SizedBox(width: 12),
              _buildSmallControl(Icons.add, onIncrease),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBright),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
