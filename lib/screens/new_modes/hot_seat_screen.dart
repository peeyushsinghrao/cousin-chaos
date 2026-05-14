import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/hot_seat_dares.dart';
import '../../widgets/glass_card.dart';

class HotSeatScreen extends StatefulWidget {
  const HotSeatScreen({Key? key}) : super(key: key);

  @override
  State<HotSeatScreen> createState() => _HotSeatScreenState();
}

class _HotSeatScreenState extends State<HotSeatScreen> {
  int selectedRounds = 5;
  int currentIndex = 0;

  void _nextDare() {
    setState(() {
      currentIndex = Random().nextInt(hotSeatDares.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Hot Seat'),
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
                    Text('Heat up the room', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Pick how many rounds to play and let the group choose the player in the hot seat. Every round brings a bold dare.',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rounds', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [3, 5, 7].map((rounds) {
                        final isSelected = selectedRounds == rounds;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedRounds = rounds),
                              child: GlassCard(
                                borderRadius: 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: Text(
                                      '$rounds',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: isSelected ? AppColors.surface : AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Current Dare', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        hotSeatDares[currentIndex],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _nextDare,
                            child: const Text('Next Dare'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap Next Dare between rounds. Use your own rules to choose who lands in the hot seat each time.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FadeInUp(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: _nextDare,
                child: const Text('Start Hot Seat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
