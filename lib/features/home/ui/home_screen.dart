import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'widgets/app_title_widget.dart';
import 'widgets/play_button_card.dart';
import 'widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),
                
                // App title
                const AppTitleWidget(),
                
                SizedBox(height: 30.h),
                
                // Play button card
                Center(
                  child: PlayButtonCard(
                    onPressed: () {
                      Get.toNamed('/rooms');
                    },
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Feature cards
                const FeatureCard(
                  icon: Icons.people_rounded,
                  title: '2-4 لاعبين',
                  description: 'لعب جماعي',
                ),
                
                SizedBox(height: 12.h),
                
                const FeatureCard(
                  icon: Icons.timer_rounded,
                  title: 'جولات سريعة',
                  description: 'الدور 10 ثواني فقط',
                ),
                
                SizedBox(height: 12.h),
                
                const FeatureCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'غرف دردشة',
                  description: 'العب ودردش',
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
