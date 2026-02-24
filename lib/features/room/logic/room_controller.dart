import 'dart:async';

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
    }
  }

  List<String> get currentWordLetters {
    final value = room.value;
    if (value == null || value.currentWord.isEmpty) {
      return const ['ك', 'ت', 'ب'];
    }
    return value.currentWord.split('');
  }

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

  List<Player> get otherPlayers {
    final id = currentUserId;
    return players.where((player) => player.id != id).toList();
  }

  String get currentPlayerName {
    final player = currentPlayer;
    if (player == null || player.name.isEmpty) {
      return 'أنت';
    }
    return player.name;
  }

  bool get isCreator {
    final value = room.value;
    final id = currentUserId;
    return value != null && id != null && value.createdBy == id;
  }

  bool get hasStarted {
    return room.value?.status == 'playing';
  }

  bool get canStartGame {
    return isCreator && !hasStarted && players.length >= 2;
  }

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
}
