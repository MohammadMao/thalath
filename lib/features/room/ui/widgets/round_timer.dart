import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class RoundTimer extends StatelessWidget {
  const RoundTimer({
    super.key,
    required this.unit,
    required this.timerText,
    this.isUrgent = false,
  });

  final double unit;
  final String timerText;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final borderColor = isUrgent
        ? Colors.red.withValues(alpha: 0.7)
        : AppTheme.primaryTeal.withValues(alpha: 0.2);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: 14 * unit,
        vertical: 6 * unit,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withValues(alpha: 0.15)
            : AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18 * unit),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        '00:$timerText',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isUrgent ? Colors.red : null,
          fontWeight: isUrgent ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
