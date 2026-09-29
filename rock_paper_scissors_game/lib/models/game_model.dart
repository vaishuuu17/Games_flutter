import 'dart:math';
import 'package:get/get.dart';
import 'move_model.dart';

class GameResult {
  final bool isWin;
  final bool isDraw;
  final MoveModel userMove;
  final MoveModel aiMove;

  const GameResult({
    required this.isWin,
    required this.isDraw,
    required this.userMove,
    required this.aiMove,
  });
}

class GameModel {
  int userScore;
  int aiScore;
  int draws;
  List<MoveModel> moves;

  GameModel({this.userScore = 0, this.aiScore = 0, this.draws = 0})
    : moves = MoveModel.moves;

  MoveModel getRandomAiMove() {
    final random = Random();
    return moves[random.nextInt(moves.length)];
  }

  GameResult playMove(MoveModel userMove) {
    final aiMove = getRandomAiMove();
    bool isDraw = userMove.name == aiMove.name;
    bool isWin = userMove.beats(aiMove);

    if (isDraw) {
      draws++;
    } else if (isWin) {
      userScore++;
    } else {
      aiScore++;
    }

    return GameResult(
      isWin: isWin,
      isDraw: isDraw,
      userMove: userMove,
      aiMove: aiMove,
    );
  }

  void resetScores() {
    userScore = 0;
    aiScore = 0;
    draws = 0;
  }
}
