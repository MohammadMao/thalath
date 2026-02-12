import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class PlayButtonCard extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButtonCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 160.w,
        height: 160.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'العب',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
