import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                      // TODO: Navigate to rooms
                    },
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Feature cards
                const FeatureCard(
                  icon: Icons.people_rounded,
                  title: '2-4 Players',
                  description: 'Play with friends in real-time',
                ),
                
                SizedBox(height: 12.h),
                
                const FeatureCard(
                  icon: Icons.timer_rounded,
                  title: 'Quick Rounds',
                  description: 'Fast-paced 10-second turns',
                ),
                
                SizedBox(height: 12.h),
                
                const FeatureCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Live Chat',
                  description: 'Chat with other players',
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
