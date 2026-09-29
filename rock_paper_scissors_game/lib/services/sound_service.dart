import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playMoveSound() async {
    await _audioPlayer.play(AssetSource('sounds/move.mp3'));
  }

  Future<void> playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/win.mp3'));
  }

  Future<void> playLoseSound() async {
    await _audioPlayer.play(AssetSource('sounds/lose.mp3'));
  }

  Future<void> playDrawSound() async {
    await _audioPlayer.play(AssetSource('sounds/draw.mp3'));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
