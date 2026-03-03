import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal.withValues(alpha: 0.2),
                  AppTheme.primaryGreen.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryTeal,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 4.h),
                if (description != null)
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
