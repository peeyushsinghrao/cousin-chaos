import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';

class PlayerAvatar extends StatefulWidget {
  final String playerName;
  final Color color;
  final bool isActive;
  final double size;
  final bool tappableToChange;
  final String? imageUrl;
  final String? emoji;

  const PlayerAvatar({
    super.key,
    required this.playerName,
    required this.color,
    this.isActive = false,
    this.size = 48,
    this.tappableToChange = false,
    this.imageUrl,
    this.emoji,
  });

  @override
  State<PlayerAvatar> createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> {
  int _seed = 0;

  String get _diceBearUrl {
    final baseSeed = widget.playerName.isNotEmpty ? widget.playerName : 'player';
    final seedStr = _seed == 0 ? baseSeed : '${baseSeed}_$_seed';
    final px = widget.size.round().clamp(40, 400);
    return 'https://api.dicebear.com/7.x/bottts/png?seed=${Uri.encodeComponent(seedStr)}&size=$px';
  }

  void _cycle() {
    setState(() => _seed++);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isActive ? widget.color : AppColors.borderGlass,
          width: widget.isActive ? 3 : 2,
        ),
        boxShadow: widget.isActive
            ? AppTheme.neonGlow(widget.color, blurRadius: 15)
            : null,
      ),
      child: ClipOval(child: _buildImage()),
    );

    if (widget.tappableToChange) {
      return GestureDetector(
        onTap: _cycle,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                avatar,
                const SizedBox(height: 4),
                _buildLabel(),
              ],
            ),
            Positioned(
              bottom: 22,
              right: 0,
              child: Container(
                width: widget.size * 0.32,
                height: widget.size * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: widget.size * 0.18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 4),
        _buildLabel(),
      ],
    );
  }

  Widget _buildImage() {
    final url = widget.imageUrl ?? _diceBearUrl;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      placeholder: (_, __) => _buildFallback(loading: true),
      errorWidget: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildFallback({bool loading = false}) {
    return Container(
      color: widget.color.withAlpha(76),
      child: Center(
        child: loading
            ? SizedBox(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.color,
                ),
              )
            : Text(
                widget.playerName.isNotEmpty
                    ? widget.playerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: widget.color,
                  fontSize: widget.size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.playerName,
      style: TextStyle(
        color:
            widget.isActive ? widget.color : AppColors.textSecondary,
        fontSize: widget.size * 0.25,
        fontWeight:
            widget.isActive ? FontWeight.bold : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
