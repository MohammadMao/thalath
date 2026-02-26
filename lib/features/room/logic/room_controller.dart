import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/models/room.dart';
import '../../../core/models/player.dart';
import '../../../core/services/room_service.dart';
import '../../../core/game_engine/game_engine.dart';
import '../../../core/helpers/logger.dart';

class RoomController extends GetxController {
  RoomController({required this.roomId});

  final String roomId;
  final RoomService _roomService = Get.find<RoomService>();
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
  String? _timerKey;
  bool _joined = false;

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
    
    logger.info('[onInit] completed, streams registered');
  }

  @override
  void onClose() {
    _roomSub?.cancel();
    _playersSub?.cancel();
    _timer?.cancel();
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
      logger.severe('[_ensureJoined] ERROR: $e');
      _joined = false;
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
    return value.currentWord.split('');  // ['ك', 'ت', 'ب']
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

    final newLetter = localHand[handIdx];

    logger.info('[playOnWordCard] Attempting: letter=$newLetter at wordIndex=$wordIndex, currentWord=$currentWord');

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

        final nextPlayerId = _getNextPlayerId();

        await _roomService.playCard(
          roomId: roomId,
          playerId: currentUserId!,
          newWord: result.newWord,
          newCardsCount: localHand.length,
          nextTurnPlayerId: nextPlayerId,
        );

        // Reset mistakes for the turn
        turnMistakes.value = 0;
        logger.info('[playOnWordCard] Firebase updated successfully');
      } catch (e) {
        logger.severe('[playOnWordCard] Firebase update failed: $e');
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
    if (!isMyTurn || isPlaying.value) return;

    const loseThreshold = 22;
    final uid = currentUserId;
    if (uid == null) return;

    isPlaying.value = true;
    try {
      if (localHand.length >= loseThreshold) {
        // Player loses
        logger.info('[drawCard] Hand at $loseThreshold, player loses');
        final nextPlayerId = _getNextPlayerId();
        await _roomService.loseAndAdvanceTurn(
          roomId: roomId,
          playerId: uid,
          newCardsCount: localHand.length,
          nextTurnPlayerId: nextPlayerId,
        );
        // Note: the players stream will update status to 'lost' reactively
      } else {
        final drawn = _engine.drawCard(localHand);
        if (drawn == null) {
          logger.severe('[drawCard] No drawable card found');
          return;
        }
        localHand.add(drawn);
        selectedHandIndex.value = null;
        logger.info('[drawCard] Drew: $drawn, new hand size: ${localHand.length}');

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

  /// Flash green/red behind word cards briefly.
  void _showFlash(Color color) {
    wordFlashColor.value = color;
    Future.delayed(const Duration(milliseconds: 500), () {
      wordFlashColor.value = null;
    });
  }
}
