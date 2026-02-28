import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/models/room.dart';
import '../../../core/models/player.dart';
import '../../../core/services/room_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/game_engine/game_engine.dart';
import '../../../core/helpers/logger.dart';
import '../ui/widgets/game_result_dialog.dart';
import '../ui/widgets/joker_picker_dialog.dart';

class RoomController extends GetxController {
  RoomController({required this.roomId});

  final String roomId;
  final RoomService _roomService = Get.find<RoomService>();
  final SoundService _soundService = Get.find<SoundService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GameEngine _engine = GameEngine();

  final Rxn<Room> room = Rxn<Room>();
  final RxList<Player> players = <Player>[].obs;
  final RxList<String> localHand = <String>[].obs;
  final RxInt remainingSeconds = 10.obs;

  /// Index of the selected card in the player's hand (null = none selected)
  final Rxn<int> selectedHandIndex = Rxn<int>();

  /// Local mistakes counter for the current turn
  final RxInt turnMistakes = RxInt(0);

  /// Flash color behind word cards (green = correct, red = wrong)
  final Rxn<Color> wordFlashColor = Rxn<Color>();

  /// Whether a play action is currently being processed
  final RxBool isPlaying = false.obs;

  StreamSubscription<Room>? _roomSub;
  StreamSubscription<List<Player>>? _playersSub;
  Timer? _timer;
  Worker? _roomWorker;
  String? _timerKey;
  bool _joined = false;
  bool _resultDialogShown = false;
  String? _prevRoomStatus; // for sound triggers
  String? _prevWord;       // for sound triggers

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    logger.info('[onInit] started for roomId=$roomId');
    
    _engine.loadDictionary().then((_) {
      logger.info('[onInit] Dictionary loaded');
    }).catchError((e) {
      logger.severe('[onInit] Failed to load dictionary: $e');
    });
    
    _roomSub = _roomService.streamRoom(roomId).listen((value) {
      logger.info('[onInit] Room stream received: status=${value.status}, currentTurn=${value.currentTurn}');
      room.value = value;
      _ensureJoined();
      _syncTimer('${value.currentTurn}|${value.status}');
      _ensureLocalHand();
    }, onError: (e) {
      logger.severe('[onInit] Room stream ERROR: $e');
    });

    _playersSub = _roomService.streamPlayers(roomId).listen((value) {
      logger.info('[onInit] Players stream received: count=${value.length}');
      players.assignAll(value);
    }, onError: (e) {
      logger.severe('[onInit] Players stream ERROR: $e');
    });

    // Watch for game-finished / replay transitions
    _roomWorker = ever(room, (Room? r) {
      final prevStatus = _prevRoomStatus;
      final prevWord   = _prevWord;
      _prevRoomStatus  = r?.status;
      _prevWord        = r?.currentWord;

      // 🔔 Game started
      if (r?.status == 'playing' && prevStatus != 'playing') {
        _soundService.playGameStart();
      }

      // 🃏 A valid card was played (word changed while game is running)
      if (r?.status == 'playing' &&
          prevWord != null &&
          r?.currentWord != prevWord) {
        _soundService.playCardPlay();
      }

      // 🏁 Game ended
      if (r?.status == 'finished' && !_resultDialogShown) {
        _resultDialogShown = true;
        _soundService.playGameEnd();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen != true) _showGameResult(r!);
        });
      } else if (r?.status == 'waiting' && _resultDialogShown) {
        // Game was replayed — reset local state for the new round
        _resultDialogShown = false;
        localHand.clear();
      }
    });

    logger.info('[onInit] completed, streams registered');
  }

  @override
  void onClose() {
    _roomSub?.cancel();
    _playersSub?.cancel();
    _timer?.cancel();
    _roomWorker?.dispose();
    super.onClose();
  }

  Future<void> _ensureJoined() async {
    if (_joined) {
      logger.info('[_ensureJoined] already joined, skipping');
      return;
    }
    logger.info('[_ensureJoined] starting ensure player in room');
    _joined = true;
    try {
      await _roomService.ensurePlayerInRoom(roomId);
      logger.info('[_ensureJoined] completed successfully');
    } catch (e) {
      _joined = false;
      final msg = e.toString();
      if (msg.contains('room-not-waiting') || msg.contains('room-full')) {
        logger.info('[_ensureJoined] Cannot join: $msg — redirecting to lobby');
        Get.offAllNamed('/lobby');
        Get.snackbar(
          'تعذّر الانضمام',
          msg.contains('full') ? 'الغرفة ممتلئة' : 'اللعبة بدأت بالفعل',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        logger.severe('[_ensureJoined] ERROR: $e');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    remainingSeconds.value = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 0) {
        timer.cancel();
        return;
      }
      remainingSeconds.value -= 1;
    });
  }

  void _syncTimer(String timerKey) {
    if (_timerKey != timerKey) {
      _timerKey = timerKey;
      _startTimer();
      // Reset selection and mistakes when turn changes
      selectedHandIndex.value = null;
      turnMistakes.value = 0;
    }
  }

  // Extract letters from current word
  List<String> get currentWordLetters {
    final value = room.value;
    if (value == null || value.currentWord.isEmpty) {
      return const ['ك', 'ت', 'ب'];  // Default word
    }
    // Use runes to properly handle Arabic characters
    final letters = value.currentWord.runes
        .map((rune) => String.fromCharCode(rune))
        .toList();
    
    // Log warning if not exactly 3 letters but still return what's there
    if (letters.length != 3) {
      logger.warning('[currentWordLetters] Invalid word length: ${letters.length}, word: ${value.currentWord}');
    }
    
    return letters;
  }

  // Find current user in players list
  Player? get currentPlayer {
    final id = currentUserId;
    if (id == null) {
      return null;
    }
    for (final player in players) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }

  // All players EXCEPT current user
  List<Player> get otherPlayers {
    final id = currentUserId;
    return players.where((player) => player.id != id).toList();
  }

  // Current user's name
  String get currentPlayerName {
    final player = currentPlayer;
    if (player == null || player.name.isEmpty) {
      return 'أنت';
    }
    return player.name;
  }

  // Is current user the room creator?
  bool get isCreator {
    final value = room.value;
    final id = currentUserId;
    return value != null && id != null && value.createdBy == id;
  }

  // Has game started?
  bool get hasStarted {
    return room.value?.status == 'playing';
  }

  // Can "Start Game" button be enabled?
  bool get canStartGame {
    return isCreator && !hasStarted && players.length >= 2;
  }

  // Timer display (e.g., "05")
  String get timerText {
    return remainingSeconds.value.toString().padLeft(2, '0');
  }

  Future<void> startGame() async {
    await _soundService.unlock(); // unblock web audio on first gesture
    await _roomService.startGame(roomId);
  }

  void _ensureLocalHand() {
    logger.info('[_ensureLocalHand] hasStarted=$hasStarted, localHandSize=${localHand.length}');
    if (!hasStarted) {
      return;
    }
    if (localHand.isNotEmpty) {
      logger.info('[_ensureLocalHand] hand already exists, skipping');
      return;
    }
    final newHand = _engine.generateHand();
    logger.info('[_ensureLocalHand] generated hand with ${newHand.length} cards');
    localHand.assignAll(newHand);
  }

  // ── Turn logic ──

  /// Has the current player lost?
  bool get isLost => currentPlayer?.status == 'lost';

  /// Is it the current user's turn? (lost players never have a turn)
  bool get isMyTurn {
    final value = room.value;
    final id = currentUserId;
    final turnIsUnclaimed = value?.currentTurn.isEmpty ?? false;
    return value != null &&
        id != null &&
        (turnIsUnclaimed || value.currentTurn == id) &&
        hasStarted &&
        !isLost;
  }

  /// Draw/forced turn-advance actions only when turn is explicitly owned.
  bool get isStrictMyTurn {
    final value = room.value;
    final id = currentUserId;
    return value != null &&
        id != null &&
        value.currentTurn == id &&
        hasStarted &&
        !isLost;
  }

  /// Select / deselect a card from the hand.
  void selectHandCard(int index) {
    if (!isMyTurn || isPlaying.value) return;
    if (index < 0 || index >= localHand.length) return;

    if (selectedHandIndex.value == index) {
      // Deselect
      selectedHandIndex.value = null;
    } else {
      selectedHandIndex.value = index;
    }
  }

  /// Attempt to play the selected hand card onto a word card position.
  Future<void> playOnWordCard(int wordIndex) async {
    if (!isMyTurn || isPlaying.value) return;

    final handIdx = selectedHandIndex.value;
    if (handIdx == null) return; // No card selected

    final currentWord = room.value?.currentWord ?? '';
    if (currentWord.isEmpty) return;

    _soundService.unlock(); // unblock web audio on first gesture

    final rawLetter = localHand[handIdx];

    // Joker card: ask the player which letter to use
    String newLetter = rawLetter;
    if (rawLetter == '?') {
      final picked = await JokerPickerDialog.show();
      if (picked == null) return; // Player cancelled — keep card selected
      newLetter = picked;
    }

    logger.info(
      '[playOnWordCard] Attempting: letter=$newLetter (raw=$rawLetter) at wordIndex=$wordIndex, currentWord=$currentWord, currentTurn=${room.value?.currentTurn}',
    );

    final result = _engine.tryPlay(
      currentWord: currentWord,
      wordIndex: wordIndex,
      newLetter: newLetter,
    );

    if (result.isValid) {
      // ✅ Valid word
      logger.info('[playOnWordCard] VALID word: ${result.newWord}');
      _showFlash(Colors.green);

      isPlaying.value = true;
      try {
        // Remove played card from hand
        localHand.removeAt(handIdx);
        selectedHandIndex.value = null;
        turnMistakes.value = 0;

        if (localHand.isEmpty) {
          // 🏆 Player wins with this move
          logger.info('[playOnWordCard] WIN with word: ${result.newWord}');
          await _roomService.winGame(
            roomId: roomId,
            winnerId: currentUserId!,
            winningWord: result.newWord,
            otherPlayerIds: players
                .where((p) => p.id != currentUserId)
                .map((p) => p.id)
                .toList(),
          );
        } else {
          final newWordCount = (room.value?.wordCount ?? 0) + 1;
          if (newWordCount >= 70) {
            // 🏁 Word limit reached — fewest cards wins
            logger.info('[playOnWordCard] Word limit reached ($newWordCount), ending game');
            final uid = currentUserId!;
            final activePlayers = players.where((p) => p.status == 'playing').toList();
            final cardCounts = activePlayers.map(
              (p) => p.id == uid ? localHand.length : p.cardsCount,
            );
            final minCards = cardCounts.reduce(min);
            final winnerIds = activePlayers
                .where((p) => (p.id == uid ? localHand.length : p.cardsCount) == minCards)
                .map((p) => p.id)
                .toList();
            final loserIds = activePlayers
                .where((p) => (p.id == uid ? localHand.length : p.cardsCount) > minCards)
                .map((p) => p.id)
                .toList();
            await _roomService.wordLimitWin(
              roomId: roomId,
              newWord: result.newWord,
              winnerIds: winnerIds,
              loserIds: loserIds,
            );
          } else {
            final nextPlayerId = _getNextPlayerId();
            await _roomService.playCard(
              roomId: roomId,
              playerId: currentUserId!,
              newWord: result.newWord,
              newCardsCount: localHand.length,
              nextTurnPlayerId: nextPlayerId,
            );
          }
        }

        logger.info('[playOnWordCard] Firebase updated successfully');
      } catch (e) {
        logger.severe('[playOnWordCard] Firebase update failed: $e');
        final msg = e.toString();
        if (msg.contains('not-your-turn')) {
          _showRaceLostPopup();
        }
      } finally {
        isPlaying.value = false;
      }
    } else {
      // ❌ Invalid word
      logger.info('[playOnWordCard] INVALID word: ${result.newWord}');
      _showFlash(Colors.red);

      turnMistakes.value += 1;
      selectedHandIndex.value = null;

      if (turnMistakes.value >= 3) {
        if (room.value?.currentTurn.isEmpty ?? false) {
          logger.info('[playOnWordCard] 3 mistakes reached before first turn claim, keeping open phase');
          turnMistakes.value = 0;
          return;
        }

        // 3 mistakes → advance turn
        logger.info('[playOnWordCard] 3 mistakes reached, advancing turn');
        isPlaying.value = true;
        try {
          final nextPlayerId = _getNextPlayerId();
          await _roomService.advanceTurn(
            roomId: roomId,
            nextTurnPlayerId: nextPlayerId,
          );
          turnMistakes.value = 0;
        } catch (e) {
          logger.severe('[playOnWordCard] advanceTurn failed: $e');
        } finally {
          isPlaying.value = false;
        }
      }
    }
  }

  /// Get the next player's ID in turn order.
  String _getNextPlayerId() {
    final currentId = currentUserId;
    // Players are in joinedAt order from Firestore
    final playingPlayers = players.where((p) => p.status == 'playing').toList();
    if (playingPlayers.isEmpty) return currentId ?? '';

    final currentIndex = playingPlayers.indexWhere((p) => p.id == currentId);
    if (currentIndex == -1) return playingPlayers.first.id;

    final nextIndex = (currentIndex + 1) % playingPlayers.length;
    return playingPlayers[nextIndex].id;
  }

  /// Draw a card from the deck.
  Future<void> drawCard() async {
    if (!isStrictMyTurn || isPlaying.value) return;

    const loseThreshold = 22;
    final uid = currentUserId;
    if (uid == null) return;

    _soundService.unlock(); // unblock web audio on first gesture

    isPlaying.value = true;
    try {
      if (localHand.length >= loseThreshold) {
        logger.info('[drawCard] Hand at $loseThreshold, player loses');
        await _resignAndCheck(uid);
      } else {
        final drawn = _engine.drawCard(localHand);
        if (drawn == null) {
          logger.severe('[drawCard] No drawable card found');
          return;
        }
        localHand.add(drawn);
        selectedHandIndex.value = null;
        logger.info('[drawCard] Drew: $drawn, new hand size: ${localHand.length}');
        _soundService.playCardDraw();

        final nextPlayerId = _getNextPlayerId();
        await _roomService.drawCard(
          roomId: roomId,
          playerId: uid,
          newCardsCount: localHand.length,
          nextTurnPlayerId: nextPlayerId,
        );
      }
    } catch (e) {
      logger.severe('[drawCard] Failed: $e');
    } finally {
      isPlaying.value = false;
    }
  }

  /// Quit mid-game: resign first if still playing, then leave the room.
  Future<void> forfeit() async {
    final uid = currentUserId;
    if (uid == null) return;
    if (isPlaying.value) return;

    isPlaying.value = true;
    try {
      logger.info('[forfeit] Player $uid forfeiting');
      if (hasStarted && !isLost) {
        await _resignAndCheck(uid);
      }
      await _doLeaveRoom(uid);
    } catch (e) {
      logger.severe('[forfeit] Failed: $e');
    } finally {
      isPlaying.value = false;
    }

    Get.offAllNamed('/lobby');
  }

  /// Shared: mark [uid] as lost. If exactly one playing player remains, they win.
  Future<void> _resignAndCheck(String uid) async {
    final otherPlaying = players
        .where((p) => p.id != uid && p.status == 'playing')
        .toList();

    if (otherPlaying.length == 1) {
      final winnerId = otherPlaying.first.id;
      logger.info('[_resignAndCheck] Last player standing: $winnerId');
      await _roomService.winGame(
        roomId: roomId,
        winnerId: winnerId,
        winningWord: room.value?.currentWord ?? '',
        otherPlayerIds: players
            .where((p) => p.id != winnerId)
            .map((p) => p.id)
            .toList(),
      );
    } else {
      // Determine next turn — must exclude uid since they're now out
      final nextPlayerId = otherPlaying.isNotEmpty
          ? otherPlaying.first.id // first of remaining is fine
          : uid;
      await _roomService.loseAndAdvanceTurn(
        roomId: roomId,
        playerId: uid,
        newCardsCount: localHand.length,
        nextTurnPlayerId: nextPlayerId,
      );
    }
  }

  /// Flash green/red behind word cards briefly.
  void _showFlash(Color color) {
    wordFlashColor.value = color;
    Future.delayed(const Duration(milliseconds: 500), () {
      wordFlashColor.value = null;
    });
  }

  void _showRaceLostPopup() {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'سبقوك',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    });
  }

  /// Replay the room (creator only). Closes dialog and resets game state.
  Future<void> replayRoom() async {
    if (Get.isDialogOpen == true) Get.back();
    try {
      await _roomService.replayRoom(
        roomId,
        players.map((p) => p.id).toList(),
      );
      logger.info('[replayRoom] Room reset successfully');
    } catch (e) {
      logger.severe('[replayRoom] Failed: $e');
    }
  }

  /// Quit the room. Creator just leaves lobby; non-creator is removed from players.
  Future<void> quitRoom() async {
    final uid = currentUserId;
    if (uid == null) return;
    if (Get.isDialogOpen == true) Get.back();
    try {
      await _doLeaveRoom(uid);
    } catch (e) {
      logger.severe('[quitRoom] Failed: $e');
    }
    Get.offAllNamed('/lobby');
  }

  /// Remove current player from the room in Firebase.
  /// Transfers creator role if needed. Deletes room if last player.
  Future<void> _doLeaveRoom(String uid) async {
    final remaining = players.where((p) => p.id != uid).toList();
    final creatorLeaving = isCreator;
    final newCreatorId = (creatorLeaving && remaining.isNotEmpty)
        ? remaining.first.id
        : null;

    await _roomService.leaveRoom(
      roomId: roomId,
      playerId: uid,
      remainingPlayerIds: remaining.map((p) => p.id).toList(),
      isCreator: creatorLeaving,
      currentStatus: room.value?.status ?? 'waiting',
      newCreatorId: newCreatorId,
    );
  }

  /// Show the game-result popup.
  void _showGameResult(Room finishedRoom) {
    final uid = currentUserId;
    final isCurrentUserWinner = finishedRoom.winnerId == uid ||
        finishedRoom.winnerIds.contains(uid);

    // Lookup winner name(s) from existing players list — no extra reads
    String winnerName = '';
    if (finishedRoom.winnerIds.length > 1) {
      // Multiple winners case (word limit)
      final winnerNames = finishedRoom.winnerIds
          .map((id) {
            final p = players.firstWhere(
              (player) => player.id == id,
              orElse: () => null as dynamic,
            ) as Player?;
            return (p != null && p.name.isNotEmpty) ? p.name : 'لاعب';
          })
          .toList();
      winnerName = winnerNames.join(' و ');
    } else if (finishedRoom.winnerId != null && finishedRoom.winnerId!.isNotEmpty) {
      // Single winner case
      final winner = players.firstWhere(
        (p) => p.id == finishedRoom.winnerId,
        orElse: () => null as dynamic,
      ) as Player?;
      if (winner != null) {
        winnerName = winner.name.isNotEmpty ? winner.name : 'لاعب';
      }
    }

    Get.dialog(
      GameResultDialog(
        isWinner: isCurrentUserWinner,
        isCreator: isCreator,
        winnerName: winnerName,
        onReplay: isCreator ? replayRoom : null,
        onStay: !isCreator ? () { if (Get.isDialogOpen == true) Get.back(); } : null,
        onQuit: quitRoom,
      ),
      barrierDismissible: false,
    );
  }
}
