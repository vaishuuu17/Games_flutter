import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'card.dart';
import 'confetti.dart';
import 'widgets/result_stat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Card Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  // Game state
  late List<CardItem> _cards;
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isChecking = false;
  int _pairsFound = 0;
  int _moves = 0;
  bool _gameCompleted = false;
  int _score = 0;
  int _bestScore = 0;
  int _consecutiveMatches = 0;

  // Timer state
  late Timer _timer;
  int _secondsElapsed = 0;

  // Confetti animation controller
  late AnimationController _confettiController;

  // Card flip sound controller
  late AnimationController _soundController;

  // Game level
  int _gridSize = 4; // 4x4 grid by default
  int get _totalPairs => (_gridSize * _gridSize) ~/ 2;

  // Game difficulty
  String _difficulty = 'Medium'; // Easy, Medium, Hard

  // Game theme
  String _theme = 'Nature'; // Nature, Animals, Food, Sports, etc.

  // Image paths for card faces
  final Map<String, List<String>> _themeImages = {
    'Nature': [
      'assets/images/mountains.jpg',
      'assets/images/beach.jpg',
      'assets/images/forest.jpg',
      'assets/images/desert.jpg',
      'assets/images/waterfall.jpg',
      'assets/images/canyon.jpg',
      'assets/images/volcano.jpg',
      'assets/images/lake.jpg',
      'assets/images/glacier.jpg',
      'assets/images/reef.jpg',
      'assets/images/aurora.jpg',
      'assets/images/savanna.jpg',
      'assets/images/meadow.jpg',
      'assets/images/cave.jpg',
      'assets/images/island.jpg',
      'assets/images/river.jpg',
    ],
    'Animals': [
      'lion.jpg',
      'elephant.jpg',
      'tiger.jpg',
      'giraffe.jpg',
      'zebra.jpg',
      'panda.jpg',
      'koala.jpg',
      'kangaroo.jpg',
      'wolf.jpg',
      'bear.jpg',
      'fox.jpg',
      'deer.jpg',
      'eagle.jpg',
      'dolphin.jpg',
      'penguin.jpg',
      'turtle.jpg',
    ],
    'Food': [
      'pizza.jpg',
      'burger.jpg',
      'sushi.jpg',
      'pasta.jpg',
      'taco.jpg',
      'salad.jpg',
      'cake.jpg',
      'icecream.jpg',
      'coffee.jpg',
      'donut.jpg',
      'croissant.jpg',
      'pancake.jpg',
      'steak.jpg',
      'soup.jpg',
      'sandwich.jpg',
      'cupcake.jpg',
    ],
    'Emoji': [
      '😀',
      '😎',
      '🤩',
      '🥳',
      '😍',
      '🤔',
      '🤯',
      '🥶',
      '👻',
      '👽',
      '🤖',
      '🎃',
      '🦄',
      '🐶',
      '🦊',
      '🐵',
    ],
    'Sports': [
      '⚽️',
      '🏀',
      '🏈',
      '⚾️',
      '🥎',
      '🎾',
      '🏐',
      '🏉',
      '🎱',
      '🏓',
      '🏸',
      '⛳️',
      '🥊',
      '🏄‍♂️',
      '🚴‍♀️',
      '⛷️',
    ],
  };

  // Use placeholder icons when images aren't available
  final List<IconData> _iconList = [
    Icons.landscape,
    Icons.pets,
    Icons.beach_access,
    Icons.emoji_nature,
    Icons.park,
    Icons.water,
    Icons.forest,
    Icons.waves,
    Icons.volcano,
    Icons.terrain,
    Icons.agriculture,
    Icons.eco,
    Icons.spa,
    Icons.grass,
    Icons.air,
    Icons.cloud,
    Icons.local_florist,
    Icons.sunny,
    Icons.wb_cloudy,
    Icons.wb_twilight,
    Icons.filter_drama,
    Icons.thunderstorm,
    Icons.wb_shade,
    Icons.brightness_5,
    Icons.brightness_3,
    Icons.nights_stay,
    Icons.ac_unit,
    Icons.whatshot,
    Icons.palette,
    Icons.camera,
    Icons.music_note,
    Icons.sports_basketball,
  ];

  // Use icons for now until we have proper images
  final List<IconData> _natureIcons = [
    Icons.landscape,
    Icons.beach_access,
    Icons.forest,
    Icons.terrain,
    Icons.waves,
    Icons.hiking,
    Icons.filter_hdr,
    Icons.water,
    Icons.ac_unit,
    Icons.water_damage,
    Icons.nightlight_round,
    Icons.grass,
    Icons.nature,
    Icons.dark_mode,
    Icons.landscape_outlined,
    Icons.park,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _soundController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    _soundController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Determine grid size based on difficulty
    switch (_difficulty) {
      case 'Easy':
        _gridSize = 4; // 4x4 grid
        break;
      case 'Medium':
        _gridSize = 6; // 6x6 grid
        break;
      case 'Hard':
        _gridSize = 8; // 8x8 grid
        break;
    }

    // Create pairs of cards
    final cardCount = _gridSize * _gridSize;
    final pairsNeeded = cardCount ~/ 2;

    // Get icons or emojis for the current theme
    List<dynamic> cardFaces = [];

    // Use icons for now
    if (_theme == 'Nature') {
      final shuffledIcons = [..._natureIcons]..shuffle();
      cardFaces = shuffledIcons.take(pairsNeeded).toList();
    } else if (_theme == 'Emoji') {
      cardFaces = _themeImages['Emoji']!.take(pairsNeeded).toList();
    } else if (_theme == 'Sports') {
      cardFaces = _themeImages['Sports']!.take(pairsNeeded).toList();
    } else {
      // Use icons as fallback
      final shuffledIcons = [..._iconList]..shuffle();
      cardFaces = shuffledIcons.take(pairsNeeded).toList();
    }

    // Create pairs of cards
    final cardPairs = <CardItem>[];
    for (var face in cardFaces) {
      cardPairs.add(CardItem(face));
      cardPairs.add(CardItem(face));
    }

    // Shuffle the cards
    _cards = cardPairs..shuffle();

    // Reset game state
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isChecking = false;
    _pairsFound = 0;
    _moves = 0;
    _gameCompleted = false;
    _secondsElapsed = 0;
    _score = 0;
    _consecutiveMatches = 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_gameCompleted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _onCardTap(int index) {
    // Play card flip sound effect
    _soundController.forward(from: 0);

    // Prevent tapping if checking pairs or card is already flipped
    if (_isChecking || _cards[index].isMatched || _cards[index].isFlipped) {
      return;
    }

    // If this is the first card selection
    if (_firstCardIndex == null) {
      setState(() {
        _firstCardIndex = index;
        _cards[index].isFlipped = true;
      });
      return;
    }

    // Prevent tapping the same card twice
    if (_firstCardIndex == index) {
      return;
    }

    // If this is the second card selection
    setState(() {
      _secondCardIndex = index;
      _cards[index].isFlipped = true;
      _isChecking = true;
      _moves++;
    });

    // Check if the cards match
    _checkForMatch();
  }

  void _checkForMatch() {
    // Delay to allow viewing the second card
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_firstCardIndex != null && _secondCardIndex != null) {
        final firstCard = _cards[_firstCardIndex!];
        final secondCard = _cards[_secondCardIndex!];

        if (firstCard.face == secondCard.face) {
          // Cards match
          setState(() {
            firstCard.isMatched = true;
            secondCard.isMatched = true;
            _pairsFound++;
            _consecutiveMatches++;

            // Calculate score - more points for consecutive matches and faster matches
            int basePoints = 100;
            int timeBonus = max(
              0,
              50 - (_secondsElapsed ~/ 10),
            ); // Time bonus decreases as time passes
            int comboBonus =
                _consecutiveMatches * 25; // Bonus for consecutive matches
            _score += basePoints + timeBonus + comboBonus;

            // Check for game completion
            if (_pairsFound == _totalPairs) {
              _gameCompleted = true;
              _confettiController.repeat();

              // Update best score if current score is higher
              if (_score > _bestScore) {
                _bestScore = _score;
              }
            }
          });
        } else {
          // Cards don't match, flip them back
          setState(() {
            firstCard.isFlipped = false;
            secondCard.isFlipped = false;
            _consecutiveMatches = 0; // Reset consecutive matches counter
          });
        }

        // Reset for next selection
        setState(() {
          _firstCardIndex = null;
          _secondCardIndex = null;
          _isChecking = false;
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      _confettiController.stop();
    });
  }

  void _changeDifficulty(String difficulty) {
    setState(() {
      _difficulty = difficulty;
      _resetGame();
    });
  }

  void _changeTheme(String theme) {
    setState(() {
      _theme = theme;
      _resetGame();
    });
  }

  String _formatTime() {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildResultStat(String label, String value, IconData icon) {
    return ResultStat(label: label, value: value, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a mobile device based on screen width
    final isPortrait = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.purple.shade800],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout(),
              if (_gameCompleted) _buildConfetti(),
              if (_gameCompleted) _buildCompletionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // Layout for portrait mode (mobile)
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildGameStats(),
        const SizedBox(height: 16),
        Expanded(child: _buildCardGrid()),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 16),
      ],
    );
  }

  // Layout for landscape mode (desktop)
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCardGrid(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(isCompact: true),
                _buildGameStats(isVertical: true),
                _buildSettingsPanel(),
                _buildControls(isVertical: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 8.0 : 16.0),
      child: isCompact
          ? Column(
              children: [
                const Text(
                  'Memory Match',
                  style: TextStyle(
                    fontSize: 24,
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(
                  child: Text(
                    'Memory Match',
                    style: TextStyle(
                      fontSize: 28,
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGameStats({bool isVertical = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isVertical
          ? Column(
              children: [
                _buildStatItem(
                  'Pairs',
                  '$_pairsFound/$_totalPairs',
                  Colors.greenAccent,
                ),
                const SizedBox(height: 8),
                _buildStatItem('Moves', '$_moves', Colors.amberAccent),
                const SizedBox(height: 8),
                _buildStatItem('Score', '$_score', Colors.pinkAccent),
                const SizedBox(height: 8),
                _buildStatItem('Best', '$_bestScore', Colors.cyanAccent),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Pairs',
                  '$_pairsFound/$_totalPairs',
                  Colors.greenAccent,
                ),
                _buildStatItem('Moves', '$_moves', Colors.amberAccent),
                _buildStatItem('Score', '$_score', Colors.pinkAccent),
                _buildStatItem('Best', '$_bestScore', Colors.cyanAccent),
              ],
            ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate card size based on available space and grid size
          final aspectRatio = MediaQuery.of(context).size.aspectRatio;
          final isPortrait = aspectRatio < 1.0;

          // Adjust spacing based on screen size
          final spacing = constraints.maxWidth < 600 ? 4.0 : 8.0;

          // Calculate optimal card size
          final cardSize =
              (constraints.maxWidth / _gridSize) - (spacing * (_gridSize / 2));

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return MemoryCard(
                card: _cards[index],
                size: cardSize,
                theme: _theme,
                onTap: () => _onCardTap(index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Difficulty:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDifficultyButton('Easy', Colors.green),
              _buildDifficultyButton('Medium', Colors.orange),
              _buildDifficultyButton('Hard', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Theme:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildThemeButton('Nature', Icons.landscape),
              _buildThemeButton('Animals', Icons.pets),
              _buildThemeButton('Food', Icons.fastfood),
              _buildThemeButton('Emoji', Icons.emoji_emotions),
              _buildThemeButton('Sports', Icons.sports_basketball),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, Color color) {
    final isSelected = _difficulty == difficulty;

    return ElevatedButton(
      onPressed: () => _changeDifficulty(difficulty),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected ? Colors.white : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color, width: isSelected ? 2 : 1),
        ),
      ),
      child: Text(difficulty),
    );
  }

  Widget _buildThemeButton(String theme, IconData icon) {
    final isSelected = _theme == theme;

    return ElevatedButton.icon(
      onPressed: () => _changeTheme(theme),
      icon: Icon(icon, size: 16),
      label: Text(theme),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.purple : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected ? Colors.white : Colors.purple.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.purple.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildControls({bool isVertical = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: isVertical
          ? Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'New Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    // Show settings dialog on mobile
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Game Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsPanel(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  label: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'New Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    // Show settings dialog on mobile
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Game Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsPanel(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  label: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildConfetti() {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: ConfettiPainter(controller: _confettiController),
        ),
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).size.width < 600;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: isPortrait ? screenWidth * 0.9 : screenWidth * 0.5,
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.deepPurple.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You completed the memory challenge!',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultStat('Time', _formatTime(), Icons.timer),
                  _buildResultStat('Moves', '$_moves', Icons.swipe),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultStat('Score', '$_score', Icons.stars),
                  _buildResultStat(
                    'Difficulty',
                    _difficulty,
                    _difficulty == 'Easy'
                        ? Icons.sentiment_very_satisfied
                        : _difficulty == 'Medium'
                            ? Icons.sentiment_satisfied
                            : Icons.sentiment_very_dissatisfied,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Well done! Ready for another challenge?',
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: Icon(Icons.replay, color: Colors.purple.shade800),
                    label: Text(
                      'Play Again',
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Change difficulty level and reset game
                      String nextDifficulty;
                      switch (_difficulty) {
                        case 'Easy':
                          nextDifficulty = 'Medium';
                          break;
                        case 'Medium':
                          nextDifficulty = 'Hard';
                          break;
                        default:
                          nextDifficulty = 'Easy';
                      }
                      _changeDifficulty(nextDifficulty);
                    },
                    icon: const Icon(Icons.arrow_upward, color: Colors.white70),
                    label: const Text(
                      'Increase Difficulty',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
