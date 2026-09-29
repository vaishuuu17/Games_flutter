class MoveModel {
  final String name;
  final String emoji;

  const MoveModel({required this.name, required this.emoji});

  static const rock = MoveModel(name: 'Rock', emoji: '✊');

  static const paper = MoveModel(name: 'Paper', emoji: '✋');

  static const scissors = MoveModel(name: 'Scissors', emoji: '✌️');

  static const List<MoveModel> moves = [rock, paper, scissors];

  // Define which moves this one beats
  bool beats(MoveModel other) {
    if (this == rock && other == scissors) return true;
    if (this == paper && other == rock) return true;
    if (this == scissors && other == paper) return true;
    return false;
  }
}
