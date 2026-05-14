import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/rank_it_prompts.dart';
import '../../widgets/glass_card.dart';

class RankItScreen extends StatefulWidget {
  const RankItScreen({Key? key}) : super(key: key);

  @override
  State<RankItScreen> createState() => _RankItScreenState();
}

class _RankItScreenState extends State<RankItScreen> {
  int currentIndex = 0;

  void _shufflePrompt() {
    setState(() {
      currentIndex = Random().nextInt(rankItPrompts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Rank It'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInDown(
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rank the group', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Share the prompt and let the group rank each player from best fit to least likely. Compare answers after the reveal.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prompt', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        rankItPrompts[currentIndex],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _shufflePrompt,
                      child: const Text('Next Prompt'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
