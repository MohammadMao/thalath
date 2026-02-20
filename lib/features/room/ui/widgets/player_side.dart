import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class PlayerSide extends StatelessWidget {
  final String name;
  final int cardCount;
  final Axis axis;
  final double scale;

  const PlayerSide({
    super.key,
    required this.name,
    required this.cardCount,
    this.axis = Axis.horizontal,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(cardCount, (_) => _SmallCardBack(scale: scale));
    final badgeRadius = 20 * scale;
    final badgePaddingH = 12 * scale;
    final badgePaddingV = 6 * scale;
    final wrapWidth = axis == Axis.horizontal ? 200 * scale : 50 * scale;
    final spacing = 6 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgePaddingH,
            vertical: badgePaddingV,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(badgeRadius),
            border: Border.all(
              color: AppTheme.primaryTeal.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: 8 * scale),

        SizedBox(
          width: wrapWidth,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            direction: axis,
            alignment: WrapAlignment.center,
            children: cards,
          ),
        ),
      ],
    );
  }
}

class _SmallCardBack extends StatelessWidget {
  final double scale;

  const _SmallCardBack({required this.scale});

  @override
  Widget build(BuildContext context) {
    final cardWidth = 20 * scale;
    final cardHeight = 28 * scale;
    final dotSize = 6 * scale;
    final radius = 6 * scale;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
