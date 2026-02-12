import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class RoomCard extends StatelessWidget {
  final String roomName;
  final int currentPlayers;
  final int maxPlayers;
  final String status;
  final VoidCallback onJoin;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.status,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting = status == 'Waiting';
    final statusColor = isWaiting ? AppTheme.primaryGreen : Colors.orange;

    return Container(
      padding: EdgeInsets.all(16.w),
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
          // Left section: Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name
                Text(
                  roomName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8.h),
                
                // Players count
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16.sp,
                      color: AppTheme.primaryTeal,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$currentPlayers/$maxPlayers لاعب',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status == 'Waiting' ? 'في الانتظار' : 'قيد اللعب',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Join button
          SizedBox(
            width: 70.w,
            height: 40.h,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'انضم',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
