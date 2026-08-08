class GameStage {
  final String id;
  final int number;
  final bool isCompleted;
  final int starsEarned;

  GameStage({
    required this.id,
    required this.number,
    this.isCompleted = false,
    this.starsEarned = 0,
  });
}
