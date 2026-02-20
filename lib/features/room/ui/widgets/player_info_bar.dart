import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class PlayerInfoBar extends StatelessWidget {
  final String playerName;
  final VoidCallback onChat;
  final double scale;

  const PlayerInfoBar({
    super.key,
    required this.playerName,
    required this.onChat,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final badgeRadius = 20 * scale;
    final badgePaddingH = 14 * scale;
    final badgePaddingV = 8 * scale;
    final buttonSize = 44 * scale;
    final iconSize = 22 * scale;
    final blurRadius = 12 * scale;
    final shadowOffset = 6 * scale;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgePaddingH,
            vertical: badgePaddingV,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(badgeRadius),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            playerName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onChat,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                  blurRadius: blurRadius,
                  offset: Offset(0, shadowOffset),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
}
