import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';

class PlayerAvatar extends StatelessWidget {
  final String playerName;
  final Color color;
  final bool isActive;
  final double size;
  final String? imageUrl;
  final String? emoji;

  const PlayerAvatar({
    super.key,
    required this.playerName,
    required this.color,
    this.isActive = false,
    this.size = 48,
    this.imageUrl,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : AppColors.borderGlass,
              width: isActive ? 3 : 2,
            ),
            boxShadow: isActive
                ? AppTheme.neonGlow(color, blurRadius: 15)
                : null,
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: TextStyle(
            color: isActive ? color : AppColors.textSecondary,
            fontSize: size * 0.25,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: color.withAlpha(76),
      child: Center(
        child: emoji != null && emoji!.isNotEmpty
            ? Text(
                emoji!,
                style: TextStyle(fontSize: size * 0.48),
              )
            : Text(
                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
