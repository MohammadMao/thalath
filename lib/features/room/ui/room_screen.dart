import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/word_cards.dart';
import 'widgets/player_hand.dart';
import 'widgets/player_info_bar.dart';
import 'widgets/opponent_card.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/helpers/logger.dart';
import '../logic/room_controller.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  RoomController? _controller;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    logger.info('[RoomScreen.initState] Starting initialization');
    try {
      final roomId = widget.roomId;
      logger.info('[RoomScreen.initState] Got roomId from widget: $roomId');

      if (roomId.isNotEmpty) {
        logger.info(
          '[RoomScreen.initState] roomId is valid, creating controller with tag: $roomId',
        );
        _roomId = roomId;
        _controller = Get.put(RoomController(roomId: roomId), tag: roomId);
        logger.info('[RoomScreen.initState] Controller created successfully');
      } else {
        logger.severe('[RoomScreen.initState] roomId is empty');
      }
    } catch (e, stackTrace) {
      logger.severe('[RoomScreen.initState] Exception: $e');
      logger.severe('[RoomScreen.initState] StackTrace: $stackTrace');
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

    final controller = _controller!;

    return Obx(() {
      if (controller.room.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final otherPlayers = controller.otherPlayers;
      final currentWord = controller.currentWordLetters;
      final timerText = controller.timerText;
      final userHand = controller.localHand;
      final isMyTurn = controller.isMyTurn;
      final selectedIdx = controller.selectedHandIndex.value;
      final flashColor = controller.wordFlashColor.value;

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

                // Quit button (top-right)
                final quitButton = Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(8 * unit),
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app_rounded),
                      color: Colors.redAccent,
                      tooltip: 'خروج',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppTheme.darkSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'خروج',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'هل تريد الخروج من اللعبة؟',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('إلغاء',
                                    style: TextStyle(color: Colors.white54)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  controller.forfeit();
                                },
                                child: const Text('خروج'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );

                // Smart player positioning
                var topPlayer = otherPlayers.isNotEmpty ? otherPlayers[0] : null;
                var rightPlayer = otherPlayers.length > 1 ? otherPlayers[0] : null;
                var leftPlayer = otherPlayers.length > 1 ? otherPlayers[1] : null;

                // For 2 total players (1 opponent): show top only
                // For 3+ total players (2+ opponents): show right, top, left
                if (otherPlayers.length == 1) {
                  topPlayer = otherPlayers[0];
                  rightPlayer = null;
                  leftPlayer = null;
                } else if (otherPlayers.length >= 2) {
                  rightPlayer = otherPlayers[0];
                  topPlayer = otherPlayers[1];
                  leftPlayer = otherPlayers.length > 2 ? otherPlayers[2] : null;
                }

                return Stack(
                  children: [
                    quitButton,
                    // RIGHT: First opponent (3+ players)
                    if (rightPlayer != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8 * unit),
                          child: SingleChildScrollView(
                            child: OpponentCard(
                              player: rightPlayer,
                              unit: unit,
                              isVertical: true,
                              isCurrentTurn: controller.room.value?.currentTurn == rightPlayer.id,
                            ),
                          ),
                        ),
                      ),

                    // TOP: Second opponent (2 or 3+ players)
                    if (topPlayer != null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8 * unit),
                          child: OpponentCard(
                            player: topPlayer,
                            unit: unit,
                            isVertical: false,
                            isCurrentTurn: controller.room.value?.currentTurn == topPlayer.id,
                          ),
                        ),
                      ),

                    // LEFT: Third opponent (3+ players)
                    if (leftPlayer != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8 * unit),
                          child: SingleChildScrollView(
                            child: OpponentCard(
                              player: leftPlayer,
                              unit: unit,
                              isVertical: true,
                              isCurrentTurn: controller.room.value?.currentTurn == leftPlayer.id,
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
                                color: AppTheme.primaryTeal.withValues(
                                  alpha: 0.2,
                                ),
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
                                color: AppTheme.primaryTeal.withValues(
                                  alpha: 0.2,
                                ),
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
                            flashColor: flashColor,
                            onCardTap: isMyTurn && selectedIdx != null
                                ? (wordIndex) =>
                                    controller.playOnWordCard(wordIndex)
                                : null,
                          ),
                          SizedBox(height: 12 * unit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: isMyTurn && !controller.isPlaying.value
                                    ? () => controller.drawCard()
                                    : null,
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
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
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
                          if ((controller.currentPlayer?.cardsCount ?? 0) == 22)
                            Padding(
                              padding: EdgeInsets.only(top: 8 * unit),
                              child: Text(
                                'وصلت حد الورق المسموح، السحبة الجاية خسارة :(',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11 * unit,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                              isMyTurn: isMyTurn,
                              score: controller.currentPlayer?.score ?? 0,
                              status: controller.currentPlayer?.status ?? 'playing',
                            ),
                            SizedBox(height: 12 * unit),
                            PlayerHand(
                              letters: userHand,
                              cardSize: handCardSize,
                              height: (80 * unit).clamp(60.0, 96.0),
                              gap: handCardGap,
                              radius: (12 * unit).clamp(10.0, 16.0),
                              selectedIndex: isMyTurn ? selectedIdx : null,
                              onCardTap: isMyTurn
                                  ? (index) =>
                                      controller.selectHandCard(index)
                                  : null,
                              isLost: controller.isLost,
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
    });
  }
}
