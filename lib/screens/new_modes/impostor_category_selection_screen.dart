import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/impostor_categories_data.dart';
import '../../core/widgets/glass_card.dart';
import '../new_modes/impostor_player_reveal_screen.dart';

class ImpostorCategorySelectionScreen extends StatefulWidget {
  final int playerCount;
  final int impostorCount;
  final bool timeLimitEnabled;
  final int timeLimitSeconds;

  const ImpostorCategorySelectionScreen({
    super.key,
    required this.playerCount,
    required this.impostorCount,
    required this.timeLimitEnabled,
    required this.timeLimitSeconds,
  });

  @override
  State<ImpostorCategorySelectionScreen> createState() =>
      _ImpostorCategorySelectionScreenState();
}

class _ImpostorCategorySelectionScreenState
    extends State<ImpostorCategorySelectionScreen> {
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = ImpostorCategoriesData.getAllCategories();
  }

  void _selectCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImpostorPlayerRevealScreen(
          category: category,
          playerCount: widget.playerCount,
          impostorCount: widget.impostorCount,
          timeLimitEnabled: widget.timeLimitEnabled,
          timeLimitSeconds: widget.timeLimitSeconds,
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
          // Animated Background
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
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Row(
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'IMPOSTOR MODE',
                        style: GoogleFonts.anybody(
                          fontSize: 36,
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
                      const SizedBox(height: 8),
                      Text(
                        'SELECT CATEGORY',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                // Categories Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.neonPink,
      AppColors.primaryNeon,
      AppColors.neonGreen,
    ];

    final colorIndex = _categories.indexOf(category) % colors.length;
    final color = colors[colorIndex];

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Glow effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '100 words',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // Hover ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectCategory(category),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
