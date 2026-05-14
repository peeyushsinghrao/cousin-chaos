import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

const List<String> judgeMeQuestions = [
  'Who has the wildest hidden talent?',
  'Who would survive longest on a deserted island?',
  'Who is most likely to forget their own birthday?',
  'Who is the best secret keeper?',
  'Who would win in a spontaneous dance-off?',
  'Who is most likely to become famous?',
  'Who is most likely to start a trend?',
  'Who is most likely to embarrass themselves in public?',
  'Who would make the best undercover agent?',
  'Who is most likely to organise the best surprise?',
];

class JudgeMeScreen extends StatefulWidget {
  const JudgeMeScreen({Key? key}) : super(key: key);

  @override
  State<JudgeMeScreen> createState() => _JudgeMeScreenState();
}

class _JudgeMeScreenState extends State<JudgeMeScreen> {
  int currentIndex = 0;

  void _shuffleQuestion() {
    setState(() {
      currentIndex = Random().nextInt(judgeMeQuestions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Judge Me'),
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
                    Text('Let the room decide', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Use this prompt deck to hand out playful judgments and start stories that reveal the group’s funniest traits.',
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
                        judgeMeQuestions[currentIndex],
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
                      onPressed: _shuffleQuestion,
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
