# Rock Paper Scissors 3D Game

A modern implementation of the classic Rock Paper Scissors game using Flutter, featuring 3D animations and sound effects.

## Features

- Beautiful 3D animations
- Sound effects
- Score tracking
- High score persistence
- Modern UI design

## Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Add sound files to the `assets/sounds` directory:
   - `click.mp3`: A short click sound for button presses
   - `win.mp3`: A victory sound effect
   - `lose.mp3`: A defeat sound effect

You can find free sound effects at:

- [Mixkit](https://mixkit.co/free-sound-effects/)
- [Freesound](https://freesound.org/)

## Running the Game

```bash
flutter run
```

## Controls

- Tap on Rock, Paper, or Scissors to make your choice
- Watch the 3D animation of the game
- See your score and high score
- Play again to try to beat your high score!

## Dependencies

- Flutter
- GetX for state management
- Rive for 3D animations
- Flutter Animate for UI animations
- Audio Players for sound effects
- Shared Preferences for score persistence
