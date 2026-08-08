class PlayerProfile {
  final int stars;
  final int coins;
  final int level;
  final int streak;
  final int totalCorrect;
  final int totalWrong;
  final String childName;
  final int childAge;
  final String avatar;
  final bool onboardingSeen;

  PlayerProfile({
    required this.stars,
    required this.coins,
    required this.level,
    required this.streak,
    required this.totalCorrect,
    required this.totalWrong,
    required this.childName,
    required this.childAge,
    required this.avatar,
    required this.onboardingSeen,
  });

  PlayerProfile copyWith({
    int? stars,
    int? coins,
    int? level,
    int? streak,
    int? totalCorrect,
    int? totalWrong,
    String? childName,
    int? childAge,
    String? avatar,
    bool? onboardingSeen,
  }) {
    return PlayerProfile(
      stars: stars ?? this.stars,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      avatar: avatar ?? this.avatar,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }
}
