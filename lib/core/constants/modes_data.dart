import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ModeData {
  final String title;
  final String description;
  final Color color;

  const ModeData({
    required this.title,
    required this.description,
    required this.color,
  });

  static const List<ModeData> chaosEvents = [
    ModeData(
      title: 'DARE!',
      description: 'Do a backflip or drink!',
      color: AppColors.dareRed,
    ),
    ModeData(
      title: 'SPEED!',
      description: 'Name 5 animals in 5 seconds. GO!',
      color: AppColors.neonYellow,
    ),
    ModeData(
      title: 'FREEZE!',
      description: 'Nobody move for 10 seconds. First to move loses.',
      color: AppColors.truthBlue,
    ),
    ModeData(
      title: 'PUNISHMENT!',
      description: 'The person holding the phone takes a penalty.',
      color: AppColors.neonPink,
    ),
    ModeData(
      title: 'EVERYONE DRINKS!',
      description: 'Cheers to chaos!',
      color: AppColors.neonGreen,
    ),
    ModeData(
      title: 'RAPID FIRE!',
      description: 'Ask the person to your left 3 questions fast.',
      color: AppColors.neonOrange,
    ),
  ];
}
