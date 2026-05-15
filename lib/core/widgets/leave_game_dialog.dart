import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Future<bool?> showLeaveGameDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Leave Game?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Progress will be lost.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep Playing'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Leave', style: TextStyle(color: AppColors.dareRed)),
        ),
      ],
    ),
  );
}
