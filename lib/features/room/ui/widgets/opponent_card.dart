import 'package:flutter/material.dart';
import '../../../../core/models/player.dart';
import '../../../../core/theming/app_theme.dart';

class OpponentCard extends StatelessWidget {
  final Player player;
  final double unit;
  final bool isVertical;
  final bool isCurrentTurn;

  const OpponentCard({
    super.key,
    required this.player,
    required this.unit,
    this.isVertical = false,
    this.isCurrentTurn = false,
  });

  Widget _trophyBadge(double unit) {
    if (player.score < 1) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 14 * unit),
        SizedBox(width: 2 * unit),
        Text(
          '${player.score}',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 11 * unit,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      // Player name with turn indicator
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrentTurn) ...
            [
              Container(
                width: 8 * unit,
                height: 8 * unit,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.7),
                      blurRadius: 6 * unit,
                      spreadRadius: 2 * unit,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4 * unit),
            ],
          if (player.status == 'lost') ...
            [
              Container(
                width: 8 * unit,
                height: 8 * unit,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4 * unit),
            ],
          Text(
            player.name.isNotEmpty ? player.name : 'لاعب',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (!isVertical && player.score >= 1) ...
            [SizedBox(width: 4 * unit), _trophyBadge(unit)],
        ],
      ),
      if (isVertical && player.score >= 1) ...
        [SizedBox(height: 4 * unit), _trophyBadge(unit)],
      SizedBox(height: isVertical ? 8 * unit : 6 * unit),
      // Cards count as small card visuals
      isVertical
          ? Column(
              spacing: 2 * unit,
              children: List.generate(
                player.cardsCount,
                (index) => Container(
                  width: 25 * unit,
                  height: 15 * unit,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4 * unit),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                      width: 1 * unit,
                    ),
                  ),
                ),
              ),
            )
          : Wrap(
              spacing: 2 * unit,
              runSpacing: 2 * unit,
              children: List.generate(
                player.cardsCount,
                (index) => Container(
                  width: 15 * unit,
                  height: 25 * unit,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4 * unit),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                      width: 1 * unit,
                    ),
                  ),
                ),
              ),
            ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxWidth: isVertical ? 60 * unit : 280 * unit,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10 * unit,
        vertical: 8 * unit,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12 * unit),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6 * unit,
              children: children,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6 * unit,
              children: children,
            ),
    );
  }
}
