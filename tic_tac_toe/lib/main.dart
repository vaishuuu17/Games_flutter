import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({Key? key}) : super(key: key);

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  // 0 means empty, 1 means player X, 2 means player O
  List<List<int>> board = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];

  List<List<AnimationController>> animControllers = [];
  List<List<Animation<double>>> animations = [];

  bool isPlayerX = true; // X starts the game
  bool gameOver = false;
  String gameStatus = "Player X's turn";

  // Score tracking
  int xScore = 0;
  int oScore = 0;
  int draws = 0;

  late AnimationController _winnerAnimController;
  late Animation<double> _winnerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each cell
    for (int i = 0; i < 3; i++) {
      animControllers.add([]);
      animations.add([]);
      for (int j = 0; j < 3; j++) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        );
        animControllers[i].add(controller);

        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        );
        animations[i].add(animation);
      }
    }

    _winnerAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _winnerAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _winnerAnimController,
        curve: Curves.elasticInOut,
      ),
    );

    _winnerAnimController.repeat(reverse: true);
  }

  @override
  void dispose() {
    for (var row in animControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    _winnerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to make it responsive
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double boardSize =
                constraints.maxWidth > 600 ? 450 : constraints.maxWidth * 0.85;

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Tic Tac Toe',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black38,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Scoreboard
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildScoreCard('Player X', xScore, Colors.redAccent),
                          _buildScoreCard('Draws', draws, Colors.white70),
                          _buildScoreCard(
                            'Player O',
                            oScore,
                            Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedBuilder(
                      animation: _winnerAnimController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: gameOver ? _winnerAnimation.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor().withOpacity(0.6),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              gameStatus,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Game board
                    Container(
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          int row = index ~/ 3;
                          int col = index % 3;
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: GestureDetector(
                              onTap:
                                  () => gameOver ? null : _makeMove(row, col),
                              child: AnimatedBuilder(
                                animation: animations[row][col],
                                builder: (context, child) {
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform:
                                        Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateY(
                                            pi * animations[row][col].value,
                                          ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getCellColor(row, col),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getCellShadowColor(
                                              row,
                                              col,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getBoardValue(row, col),
                                          style: TextStyle(
                                            fontSize: boardSize / 6,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 10.0,
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                offset: const Offset(2.0, 2.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                          'New Game',
                          Colors.green,
                          Icons.refresh,
                          _resetGame,
                        ),
                        const SizedBox(width: 15),
                        _buildButton(
                          'Reset Score',
                          Colors.redAccent,
                          Icons.delete_sweep,
                          _resetScore,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 5),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }

  Color _getStatusColor() {
    if (gameStatus.contains('X wins')) {
      return Colors.redAccent;
    } else if (gameStatus.contains('O wins')) {
      return Colors.blueAccent;
    } else if (gameStatus.contains('draw')) {
      return Colors.purple;
    } else if (gameStatus.contains('X\'s turn')) {
      return Colors.redAccent.withOpacity(0.7);
    } else {
      return Colors.blueAccent.withOpacity(0.7);
    }
  }

  Color _getCellColor(int row, int col) {
    if (board[row][col] == 1) {
      return Colors.redAccent.withOpacity(0.8);
    } else if (board[row][col] == 2) {
      return Colors.blueAccent.withOpacity(0.8);
    }
    return Colors.white.withOpacity(0.1);
  }

  Color _getCellShadowColor(int row, int col) {
    if (board[row][col] == 1) {
      return Colors.redAccent.withOpacity(0.5);
    } else if (board[row][col] == 2) {
      return Colors.blueAccent.withOpacity(0.5);
    }
    return Colors.white.withOpacity(0.1);
  }

  String _getBoardValue(int row, int col) {
    if (board[row][col] == 1) {
      return 'X';
    } else if (board[row][col] == 2) {
      return 'O';
    }
    return '';
  }

  void _makeMove(int row, int col) {
    // If cell is already occupied or game is over, do nothing
    if (board[row][col] != 0 || gameOver) {
      return;
    }

    setState(() {
      board[row][col] = isPlayerX ? 1 : 2;
      animControllers[row][col].forward();

      // Check for winner
      if (_checkWinner()) {
        gameStatus = "Player ${isPlayerX ? 'X' : 'O'} wins!";
        gameOver = true;
        if (isPlayerX) {
          xScore++;
        } else {
          oScore++;
        }
        _winnerAnimController.reset();
        _winnerAnimController.repeat(reverse: true);
      } else if (_isBoardFull()) {
        gameStatus = "It's a draw!";
        gameOver = true;
        draws++;
      } else {
        isPlayerX = !isPlayerX;
        gameStatus = "Player ${isPlayerX ? 'X' : 'O'}'s turn";
      }
    });
  }

  bool _checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != 0 &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != 0 &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] != 0 &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return true;
    }

    if (board[0][2] != 0 &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return true;
    }

    return false;
  }

  bool _isBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void _resetGame() {
    setState(() {
      board = [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
      ];
      isPlayerX = true;
      gameOver = false;
      gameStatus = "Player X's turn";

      // Reset animations
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          animControllers[i][j].reset();
        }
      }
    });
  }

  void _resetScore() {
    setState(() {
      xScore = 0;
      oScore = 0;
      draws = 0;
      _resetGame();
    });
  }
}
