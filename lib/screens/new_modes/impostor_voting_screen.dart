import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../new_modes/impostor_result_screen.dart';

class ImpostorVotingScreen extends StatefulWidget {
  final int playerCount;
  final List<int> impostorIndices;
  final String secretWord;
  final bool timeLimitEnabled;
  final int timeLimitSeconds;

  const ImpostorVotingScreen({
    super.key,
    required this.playerCount,
    required this.impostorIndices,
    required this.secretWord,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
  });

  @override
  State<ImpostorVotingScreen> createState() => _ImpostorVotingScreenState();
}

class _ImpostorVotingScreenState extends State<ImpostorVotingScreen> {
  int? _selectedVote;

  void _revealResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ImpostorResultScreen(
          playerCount: widget.playerCount,
          impostorIndices: widget.impostorIndices,
          secretWord: widget.secretWord,
          selectedVote: _selectedVote,
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
          // Cinematic background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.background,
                    AppColors.secondary.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Title
                  Text(
                    'VOTING PHASE',
                    style: GoogleFonts.anybody(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time to discuss and vote for the impostor!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // How to Vote Section
                  Text(
                    'HOW TO VOTE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Vote Steps
                  _buildVoteStep(
                    number: '1',
                    title: 'Starting Player',
                    subtitle: 'The first player starts the discussion',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  _buildVoteStep(
                    number: '2',
                    title: 'Group Discussion',
                    subtitle: 'Everyone shares suspicions and facts',
                    icon: Icons.chat_bubble,
                  ),
                  const SizedBox(height: 12),
                  _buildVoteStep(
                    number: '3',
                    title: 'Vote Time',
                    subtitle: 'Vote for who you think is the impostor',
                    icon: Icons.how_to_vote,
                  ),
                  const SizedBox(height: 12),
                  _buildVoteStep(
                    number: '4',
                    title: 'Reveal Phase',
                    subtitle: 'See who actually was the impostor',
                    icon: Icons.lightbulb,
                  ),
                  const SizedBox(height: 40),
                  // Player Vote Selection
                  Text(
                    'WHO DO YOU VOTE FOR?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: widget.playerCount,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedVote == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedVote = index);
                        },
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: -5,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.2)
                                        : AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'P${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme.labelMedium
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Reveal Results Button
                  GestureDetector(
                    onTap: _selectedVote != null ? _revealResults : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            _selectedVote != null
                                ? AppColors.error
                                : AppColors.error.withOpacity(0.5),
                            _selectedVote != null
                                ? AppColors.dareRed
                                : AppColors.dareRed.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: _selectedVote != null
                            ? [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'REVEAL RESULTS',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteStep({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primary, size: 24),
        ],
      ),
    );
  }
}
