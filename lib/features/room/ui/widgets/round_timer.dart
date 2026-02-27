import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class RoundTimer extends StatelessWidget {
  const RoundTimer({
    super.key,
    required this.unit,
    required this.timerText,
  });

  final double unit;
  final String timerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * unit,
        vertical: 6 * unit,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18 * unit),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '00:$timerText',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
