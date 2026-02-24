import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/player_side.dart';
import 'widgets/word_cards.dart';
import 'widgets/player_hand.dart';
import 'widgets/player_info_bar.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/models/player.dart';
import '../logic/room_controller.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  RoomController? _controller;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final roomId = args?['roomId'] as String?;
    if (roomId != null && roomId.isNotEmpty) {
      _roomId = roomId;
      _controller = Get.put(RoomController(roomId: roomId), tag: roomId);
    }
  }

  @override
  void dispose() {
    if (_roomId != null) {
      Get.delete<RoomController>(tag: _roomId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_roomId == null || _roomId!.isEmpty || _controller == null) {
      return const Scaffold(
        body: Center(child: Text('معرّف الغرفة غير متوفر')),
      );
    }

    return GetX<RoomController>(
      tag: _roomId,
      builder: (controller) {
        if (controller.room.value == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final otherPlayers = controller.otherPlayers;
        final currentWord = controller.currentWordLetters;
        final timerText = controller.timerText;
        final userHand = controller.localHand;

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

                  Widget buildPlayerChip(Player player) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * unit,
                        vertical: 6 * unit,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(18 * unit),
                        border: Border.all(
                          color:
                              AppTheme.primaryTeal.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        player.name.isNotEmpty ? player.name : 'لاعب',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      // Top players list (right-to-left by join time)
                      if (otherPlayers.isNotEmpty)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * unit),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (int i = 0;
                                        i < otherPlayers.length;
                                        i++) ...[
                                      buildPlayerChip(otherPlayers[i]),
                                      if (i != otherPlayers.length - 1)
                                        SizedBox(width: 8 * unit),
                                    ],
                                  ],
                                ),
                              ),
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
                                horizontal: 14 * unit,
                                vertical: 6 * unit,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(18 * unit),
                                border: Border.all(
                                  color: AppTheme.primaryTeal
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                '00:$timerText',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            SizedBox(height: 10 * unit),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * unit,
                                vertical: 6 * unit,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(20 * unit),
                                border: Border.all(
                                  color: AppTheme.primaryTeal
                                      .withValues(alpha: 0.2),
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
                            SizedBox(height: 12 * unit),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('سحب'),
                                ),
                                SizedBox(width: 12 * unit),
                                if (controller.isCreator &&
                                    !controller.hasStarted)
                                  ElevatedButton(
                                    onPressed: controller.canStartGame
                                        ? () async {
                                            try {
                                              await controller.startGame();
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('خطأ: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        : null,
                                    child: const Text('ابدأ اللعب'),
                                  ),
                              ],
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
                                playerName: controller.currentPlayerName,
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
      },
    );
  }
}
