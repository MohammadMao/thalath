import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class PlayerSide extends StatelessWidget {
  final String name;
  final int cardCount;
  final Axis axis;

  const PlayerSide({
    super.key,
    required this.name,
    required this.cardCount,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(cardCount, (_) => _SmallCardBack());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20.r),
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
        
        SizedBox(height: 8.h),
        
        SizedBox(
          width: axis == Axis.horizontal ? 200.w : 50.w,
          child: Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
