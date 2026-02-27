import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SoundService extends GetxService {
  // One dedicated player per sound — no interference between overlapping plays
  late final AudioPlayer _gameStartPlayer;
  late final AudioPlayer _cardDrawPlayer;
  late final AudioPlayer _cardPlayPlayer;
  late final AudioPlayer _gameEndPlayer;
  late final AudioPlayer _gameOpenPlayer;

  bool _unlocked = false;

  @override
  void onInit() {
    super.onInit();
    _gameStartPlayer = AudioPlayer();
    _cardDrawPlayer  = AudioPlayer();
    _cardPlayPlayer  = AudioPlayer();
    _gameEndPlayer   = AudioPlayer();
    _gameOpenPlayer  = AudioPlayer();

    // Pre-load assets so first play has no delay
    AudioCache.instance.loadAll([
      'sounds/game_start.mp3',
      'sounds/card_draw.mp3',
      'sounds/card_play.mp3',
      'sounds/game_end.mp3',
      'sounds/game_open.mp3',
    ]);
  }

  @override
  void onClose() {
    _gameStartPlayer.dispose();
    _cardDrawPlayer.dispose();
    _cardPlayPlayer.dispose();
    _gameEndPlayer.dispose();
    _gameOpenPlayer.dispose();
    super.onClose();
  }

  /// Call on the first user gesture (any button tap) to unblock web AudioContext.
  Future<void> unlock() async {
    if (_unlocked) return;
    _unlocked = true;
    if (kIsWeb) {
      try {
        // Resuming at volume 0 satisfies browser autoplay policy
        await _cardPlayPlayer.setVolume(0);
        await _cardPlayPlayer.play(AssetSource('sounds/card_play.mp3'));
        await _cardPlayPlayer.setVolume(1);
      } catch (_) {}
    }
  }

  Future<void> _play(AudioPlayer player, String asset) async {
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Sound failure must never affect gameplay
    }
  }

  Future<void> playGameStart() => _play(_gameStartPlayer, 'sounds/game_start.mp3');
  Future<void> playCardDraw()  => _play(_cardDrawPlayer,  'sounds/card_draw.mp3');
  Future<void> playCardPlay()  => _play(_cardPlayPlayer,  'sounds/card_play.mp3');
  Future<void> playGameEnd()   => _play(_gameEndPlayer,   'sounds/game_end.mp3');
  Future<void> playGameOpen()  => _play(_gameOpenPlayer,  'sounds/game_open.mp3');
}
