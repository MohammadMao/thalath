import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'widgets/player_side.dart';
import 'widgets/word_cards.dart';
import 'widgets/player_hand.dart';
import 'widgets/player_info_bar.dart';
import '../../../core/theming/app_theme.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final currentWord = ['ب', 'ت', 'ك'];
    final userHand = ['ذ', 'و', 'ب', 'ب', 'ا', 'غ', 'ع', 'غ', 'س', 'ص', 'ذ', 'ط'];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top player
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: const PlayerSide(
                  name: 'أحمد',
                  cardCount: 8,
                  axis: Axis.horizontal,
                ),
              ),
            ),

            // Left player
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: const PlayerSide(
                  name: 'فاطمة',
                  cardCount: 5,
                  axis: Axis.vertical,
                ),
              ),
            ),

            // Right player
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: const PlayerSide(
                  name: 'محمد',
                  cardCount: 10,
                  axis: Axis.vertical,
                ),
              ),
            ),

            // Center word
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'الكلمة الحالية',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  WordCards(letters: currentWord),
                ],
              ),
            ),

            // Bottom player info + hand
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerInfoBar(
                      playerName: 'أنت',
                      onChat: () {
                        Get.snackbar('الدردشة', 'زر الدردشة');
                      },
                    ),
                    SizedBox(height: 12.h),
                    PlayerHand(letters: userHand),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
