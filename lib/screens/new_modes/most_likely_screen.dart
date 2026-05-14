import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/most_likely_prompts.dart';
import '../../widgets/glass_card.dart';

class MostLikelyScreen extends StatefulWidget {
  const MostLikelyScreen({Key? key}) : super(key: key);

  @override
  State<MostLikelyScreen> createState() => _MostLikelyScreenState();
}

class _MostLikelyScreenState extends State<MostLikelyScreen> {
  String currentCategory = mostLikelyPrompts.keys.first;
  int currentIndex = 0;

  void _shufflePrompt() {
    final prompts = mostLikelyPrompts[currentCategory]!;
    setState(() {
      currentIndex = Random().nextInt(prompts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prompts = mostLikelyPrompts[currentCategory]!;
    final prompt = prompts[currentIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Most Likely To'),
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
                    Text('Who is most likely?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the player who fits the prompt best, then keep the conversation going with the story behind the choice.',
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
                    Text('Category', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: mostLikelyPrompts.keys.map((category) {
                        final selected = category == currentCategory;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          backgroundColor: AppColors.surfaceContainer,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.surface : AppColors.onSurface,
                          ),
                          onSelected: (_) {
                            setState(() {
                              currentCategory = category;
                              currentIndex = 0;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Prompt', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        prompt,
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
