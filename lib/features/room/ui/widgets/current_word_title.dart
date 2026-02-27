import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class CurrentWordTitle extends StatelessWidget {
  const CurrentWordTitle({
    super.key,
    required this.unit,
  });

  final double unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * unit,
        vertical: 6 * unit,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20 * unit),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'الكلمة الحالية',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
