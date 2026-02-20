import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/player_side.dart';
import 'widgets/word_cards.dart';
import 'widgets/player_hand.dart';
import 'widgets/player_info_bar.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final currentWord = ['ب', 'ت', 'ك'];
    final userHand = ['ذ', 'و', 'ب', 'ب', 'ا', 'غ', 'ع', 'غ', 'س', 'ص', 'ذ', 'ط'];

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final unit = (constraints.maxWidth / 375).clamp(0.9, 1.2);
              final wordCardSize = (90 * unit).clamp(70.0, 110.0);
              final wordCardGap = (12 * unit).clamp(8.0, 16.0);
              final handCardSize = (56 * unit).clamp(44.0, 68.0);
              final handCardGap = (8 * unit).clamp(6.0, 12.0);

              return Stack(
                children: [
                  // Top player
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 12 * unit),
                      child: PlayerSide(
                        name: 'أحمد',
                        cardCount: 8,
                        axis: Axis.horizontal,
                        scale: unit,
                      ),
                    ),
                  ),

                  // Left player
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8 * unit),
                      child: PlayerSide(
                        name: 'فاطمة',
                        cardCount: 5,
                        axis: Axis.vertical,
                        scale: unit,
                      ),
                    ),
                  ),

                  // Right player
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8 * unit),
                      child: PlayerSide(
                        name: 'محمد',
                        cardCount: 10,
                        axis: Axis.vertical,
                        scale: unit,
                      ),
                    ),
                  ),

                  // Center word
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
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
                        ),
                        SizedBox(height: 16 * unit),
                        WordCards(
                          letters: currentWord,
                          cardSize: wordCardSize,
                          gap: wordCardGap,
                          radius: (16 * unit).clamp(12.0, 20.0),
                        ),
                      ],
                    ),
                  ),

                  // Bottom player info + hand
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16 * unit,
                        right: 16 * unit,
                        bottom: 16 * unit,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerInfoBar(
                            playerName: 'أنت',
                            onChat: () {
                              Get.snackbar('الدردشة', 'زر الدردشة');
                            },
                            scale: unit,
                          ),
                          SizedBox(height: 12 * unit),
                          PlayerHand(
                            letters: userHand,
                            cardSize: handCardSize,
                            height: (80 * unit).clamp(60.0, 96.0),
                            gap: handCardGap,
                            radius: (12 * unit).clamp(10.0, 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
