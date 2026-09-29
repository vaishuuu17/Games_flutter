import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_model.dart'; // Import GameModel
import '../utils/constants.dart';
import '../views/screens/result_screen.dart';
import '../models/move_model.dart';

class GameController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _random = Random();
  final _prefs = SharedPreferences.getInstance();

  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;
  final RxString result = ''.obs;
  final Rx<Color> resultColor = Colors.white.obs;
  final RxString computerChoice = ''.obs;
  final RxBool showPlayAgain = false.obs;
  final RxBool isAnimating = false.obs;
  final Rx<MoveModel?> lastResult = Rx<MoveModel?>(null);
  final Rx<GameModel> gameModel = GameModel().obs;

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await _prefs;
    highScore.value = prefs.getInt('highScore') ?? 0;
  }

  Future<void> _saveHighScore() async {
    final prefs = await _prefs;
    await prefs.setInt('highScore', highScore.value);
  }

  Future<void> playMove(MoveModel move) async {
    isAnimating.value = true;

    // Play sound effect
    await _audioPlayer.play(AssetSource('sounds/click.mp3'));

    // Generate computer's choice
    final choices = MoveModel.moves;
    final computerMove = choices[_random.nextInt(choices.length)];
    computerChoice.value = computerMove.name;

    // Short delay for animation
    await Future.delayed(const Duration(milliseconds: 1000));

    // Determine winner
    String gameResult;
    Color color;
    bool isWin = false;

    if (move.name == computerMove.name) {
      gameResult = AppText.draw;
      color = AppColors.drawColor;
    } else if (move.beats(computerMove)) {
      gameResult = AppText.win;
      color = AppColors.winColor;
      isWin = true;
      score.value++;
      if (score.value > highScore.value) {
        highScore.value = score.value;
        await _saveHighScore();
      }
      await _audioPlayer.play(AssetSource('sounds/win.mp3'));
    } else {
      gameResult = AppText.lose;
      color = AppColors.loseColor;
      score.value = 0;
      await _audioPlayer.play(AssetSource('sounds/lose.mp3'));
    }

    result.value = gameResult;
    resultColor.value = color;
    showPlayAgain.value = true;
    isAnimating.value = false;

    // Navigate to result screen
    Get.to(
      () => ResultScreen(
        result: gameResult,
        resultColor: color,
        playerMove: move.name,
        computerMove: computerMove.name,
        isWin: isWin,
      ),
    );
  }

  void makeChoice(String playerChoice) async {
    final move = MoveModel.moves.firstWhere(
      (m) => m.name == playerChoice,
      orElse: () => MoveModel.rock,
    );
    await playMove(move);
  }

  void resetGame() {
    result.value = '';
    computerChoice.value = '';
    showPlayAgain.value = false;
  }
}
