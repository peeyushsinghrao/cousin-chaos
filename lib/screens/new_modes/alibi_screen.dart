import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/alibi_questions.dart';
import '../../widgets/glass_card.dart';

class AlibiScreen extends StatefulWidget {
  const AlibiScreen({Key? key}) : super(key: key);

  @override
  State<AlibiScreen> createState() => _AlibiScreenState();
}

class _AlibiScreenState extends State<AlibiScreen> {
  String category = alibiQuestionsByCategory.keys.first;
  int currentIndex = 0;

  void _shuffleQuestion() {
    final questions = alibiQuestionsByCategory[category]!;
    setState(() {
      currentIndex = Random().nextInt(questions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = alibiQuestionsByCategory[category]!;
    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Alibi'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FadeInDown(
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create your story', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Pick a category and build an alibi for the situation. Use clever details and keep the group guessing.',
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
                      children: alibiQuestionsByCategory.keys.map((value) {
                        final selected = value == category;
                        return ChoiceChip(
                          label: Text(value),
                          selected: selected,
                          backgroundColor: AppColors.surfaceContainer,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.surface : AppColors.onSurface,
                          ),
                          onSelected: (_) {
                            setState(() {
                              category = value;
                              currentIndex = 0;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Current Prompt', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _shuffleQuestion,
                      child: const Text('New Prompt'),
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
