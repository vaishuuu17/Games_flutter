import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> with TickerProviderStateMixin {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final fontStyle = const TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();
  late AnimationController _powerUpController;
  late Animation<double> _powerUpAnimation;

  List<List<int>> snake = [];
  List<int> food = [];
  List<int> powerUp = [];
  List<List<int>> obstacles = [];
  String direction = 'up';
  bool isPlaying = false;
  bool isPaused = false;
  int score = 0;
  int highScore = 0;
  int level = 1;
  bool hasPowerUp = false;
  String powerUpType = '';
  int powerUpTimer = 0;
  int gameSpeed = 150;
  bool isShieldActive = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _powerUpController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _powerUpAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _powerUpController, curve: Curves.easeInOut),
    );
    _powerUpController.repeat(reverse: true);
    loadHighScore();
    initializeGame();
  }

  void initializeGame() {
    setState(() {
      snake = [
        [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()],
        [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor() + 1],
      ];
      direction = 'up';
      score = 0;
      level = 1;
      gameSpeed = 150;
      isPlaying = false;
      isPaused = false;
      hasPowerUp = false;
      powerUpType = '';
      food = [];
      powerUp = [];
      obstacles = [];
      createFood();
      createObstacles();
    });
  }

  @override
  void dispose() {
    _powerUpController.dispose();
    gameTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        highScore = prefs.getInt('highScore') ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading high score: $e');
    }
  }

  Future<void> saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
    } catch (e) {
      debugPrint('Error saving high score: $e');
    }
  }

  void startGame() {
    if (gameTimer != null) {
      gameTimer!.cancel();
    }
    
    setState(() {
      initializeGame();
      isPlaying = true;
    });

    gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (Timer timer) {
      if (!isPaused && isPlaying) {
        moveSnake();
        if (checkGameOver()) {
          timer.cancel();
          endGame();
        }
        updatePowerUp();
      }
    });
  }

  void createObstacles() {
    obstacles.clear();
    int obstacleCount = (level * 2).clamp(2, 10);
    for (int i = 0; i < obstacleCount; i++) {
      int x, y;
      do {
        x = randomGen.nextInt(squaresPerRow);
        y = randomGen.nextInt(squaresPerCol);
      } while (isPositionOccupied(x, y));
      obstacles.add([x, y]);
    }
  }

  void createPowerUp() {
    if (randomGen.nextDouble() < 0.3) {
      int x, y;
      do {
        x = randomGen.nextInt(squaresPerRow);
        y = randomGen.nextInt(squaresPerCol);
      } while (isPositionOccupied(x, y));
      powerUp = [x, y];
      powerUpType = ['speed', 'shield', 'points'][randomGen.nextInt(3)];
      powerUpTimer = 50;
    }
  }

  void updatePowerUp() {
    if (powerUp.isNotEmpty) {
      powerUpTimer--;
      if (powerUpTimer <= 0) {
        powerUp.clear();
        hasPowerUp = false;
        gameSpeed = 150;
      }
    }
  }

  bool isPositionOccupied(int x, int y) {
    for (var pos in snake) {
      if (pos[0] == x && pos[1] == y) return true;
    }
    for (var obstacle in obstacles) {
      if (obstacle[0] == x && obstacle[1] == y) return true;
    }
    if (food.isNotEmpty && food[0] == x && food[1] == y) return true;
    return false;
  }

  void moveSnake() {
    if (snake.isEmpty) return;

    setState(() {
      var newHead = List<int>.from(snake.first);
      
      switch (direction) {
        case "up":
          newHead[1]--;
          break;
        case "down":
          newHead[1]++;
          break;
        case "left":
          newHead[0]--;
          break;
        case "right":
          newHead[0]++;
          break;
      }

      snake.insert(0, newHead);

      if (food.isNotEmpty && newHead[0] == food[0] && newHead[1] == food[1]) {
        score += 10;
        if (score > highScore) {
          highScore = score;
          saveHighScore();
        }
        createFood();
        if (score % 50 == 0) {
          levelUp();
        }
      } else {
        snake.removeLast();
      }

      if (powerUp.isNotEmpty && newHead[0] == powerUp[0] && newHead[1] == powerUp[1]) {
        activatePowerUp();
        powerUp.clear();
      }
    });
  }

  void activatePowerUp() {
    hasPowerUp = true;
    switch (powerUpType) {
      case 'speed':
        gameSpeed = 100;
        break;
      case 'shield':
        isShieldActive = true;
        break;
      case 'points':
        score += 30;
        break;
    }
  }

  void levelUp() {
    level++;
    gameSpeed = (150 - (level * 5)).clamp(50, 150);
    createObstacles();
  }

  void createFood() {
    int x, y;
    do {
      x = randomGen.nextInt(squaresPerRow);
      y = randomGen.nextInt(squaresPerCol);
    } while (isPositionOccupied(x, y));
    food = [x, y];
  }

  bool checkGameOver() {
    if (snake.isEmpty) return true;
    
    if (!isPlaying ||
        snake.first[0] < 0 ||
        snake.first[0] >= squaresPerRow ||
        snake.first[1] < 0 ||
        snake.first[1] >= squaresPerCol) {
      return !isShieldActive;
    }

    for (var obstacle in obstacles) {
      if (snake.first[0] == obstacle[0] && snake.first[1] == obstacle[1]) {
        return !isShieldActive;
      }
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return !isShieldActive;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 30),
              const SizedBox(width: 10),
              Text(
                "Game Over",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "High Score: $highScore",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Level: $level",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Play Again"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Exit"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Score: $score", style: fontStyle),
                  Text("Level: $level", style: fontStyle),
                  Text("High Score: $highScore", style: fontStyle),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (direction != 'up' && details.delta.dy > 0) {
                    direction = 'down';
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (direction != 'left' && details.delta.dx > 0) {
                    direction = 'right';
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    direction = 'left';
                  }
                },
                child: AspectRatio(
                  aspectRatio: squaresPerRow / (squaresPerCol + 5),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squaresPerRow,
                    ),
                    itemCount: squaresPerRow * squaresPerCol,
                    itemBuilder: (BuildContext context, int index) {
                      Color? color;
                      var x = index % squaresPerRow;
                      var y = (index / squaresPerRow).floor();

                      bool isSnakeBody = false;
                      for (var pos in snake) {
                        if (pos[0] == x && pos[1] == y) {
                          isSnakeBody = true;
                          break;
                        }
                      }

                      if (snake.isNotEmpty && snake.first[0] == x && snake.first[1] == y) {
                        color = Colors.green;
                      } else if (isSnakeBody) {
                        color = Colors.green[200];
                      } else if (food.isNotEmpty && food[0] == x && food[1] == y) {
                        color = Colors.red;
                      } else if (powerUp.isNotEmpty &&
                          powerUp[0] == x &&
                          powerUp[1] == y) {
                        color = Colors.yellow;
                      } else if (obstacles
                          .any((obs) => obs[0] == x && obs[1] == y)) {
                        color = Colors.brown;
                      } else {
                        color = Colors.grey[800];
                      }

                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (powerUp.isNotEmpty &&
                                powerUp[0] == x &&
                                powerUp[1] == y)
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isPlaying) {
                        setState(() {
                          isPaused = !isPaused;
                        });
                      } else {
                        startGame();
                      }
                    },
                    icon: Icon(isPlaying
                        ? (isPaused ? Icons.play_arrow : Icons.pause)
                        : Icons.play_arrow),
                    label: Text(
                        isPlaying ? (isPaused ? "Resume" : "Pause") : "Start"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying
                          ? (isPaused ? Colors.green : Colors.orange)
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                  if (hasPowerUp)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            powerUpType == 'speed'
                                ? Icons.speed
                                : powerUpType == 'shield'
                                    ? Icons.shield
                                    : Icons.star,
                            color: Colors.yellow,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            powerUpType.toUpperCase(),
                            style: const TextStyle(color: Colors.yellow),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
