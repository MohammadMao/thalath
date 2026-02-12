import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class AppTitleWidget extends StatelessWidget {
  const AppTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App title with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'ثلاث',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 80.sp,
            ),
          ),
        ),
        
        SizedBox(height: 8.h),
        
        // Subtitle
        Text(
          'Thalath',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
          ),
        ),
        
        SizedBox(height: 4.h),
        
        Text(
          'اختبر مفرداتك',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
