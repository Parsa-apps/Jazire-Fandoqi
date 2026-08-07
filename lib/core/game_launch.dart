/// Optional context passed when a game is opened from the stage map.
///
/// Quick-play entries intentionally omit this context, so replaying a quick
/// game never changes map progress. A stage reward is claimed only after the
/// corresponding game reports a successful completion.
class GameLaunch {
  final String gameName;
  final String? stageId;
  final int? stageNumber;

  const GameLaunch({
    required this.gameName,
    this.stageId,
    this.stageNumber,
  });
}
