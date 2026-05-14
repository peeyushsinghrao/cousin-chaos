import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/two_truths_one_lie.dart';
import '../../widgets/glass_card.dart';

class TwoTruthsOneLieScreen extends StatefulWidget {
  const TwoTruthsOneLieScreen({Key? key}) : super(key: key);

  @override
  State<TwoTruthsOneLieScreen> createState() => _TwoTruthsOneLieScreenState();
}

class _TwoTruthsOneLieScreenState extends State<TwoTruthsOneLieScreen> {
  int currentIndex = 0;

  void _shuffleExample() {
    setState(() {
      currentIndex = Random().nextInt(exampleSets.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final example = exampleSets[currentIndex];
    final statements = (example['statements'] as List).cast<String>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Two Truths One Lie'),
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
                    Text('Truth or bluff?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Present these three statement slots to the group. Let them guess the lie and then share the real story.',
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
                    ...List.generate(statements.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            statements[i],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _shuffleExample,
                      child: const Text('Shuffle Statements'),
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
