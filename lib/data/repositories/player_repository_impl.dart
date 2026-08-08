import '../../core/game_data.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/local_data_source.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final LocalDataSource _localDataSource;

  PlayerRepositoryImpl(this._localDataSource);

  @override
  Future<PlayerProfile> getProfile() async {
    final cachedData = _localDataSource.getPlayerData();
    
    if (cachedData != null) {
      return PlayerProfile(
        stars: cachedData['stars'] ?? 0,
        coins: cachedData['coins'] ?? 0,
        level: cachedData['level'] ?? 1,
        streak: cachedData['streak'] ?? 0,
        totalCorrect: cachedData['totalCorrect'] ?? 0,
        totalWrong: cachedData['totalWrong'] ?? 0,
        childName: cachedData['childName'] ?? '',
        childAge: cachedData['childAge'] ?? 5,
        avatar: cachedData['avatar'] ?? '😊',
        onboardingSeen: cachedData['onboardingSeen'] ?? false,
      );
    }

    // If no Hive data, try to load from old GameData (SharedPreferences)
    if (!GameData.isLoaded) {
      await GameData.load();
    }
    
    final profile = PlayerProfile(
      stars: GameData.stars,
      coins: GameData.coins,
      level: GameData.level,
      streak: GameData.streak,
      totalCorrect: GameData.totalCorrect,
      totalWrong: GameData.totalWrong,
      childName: GameData.childName,
      childAge: GameData.childAge,
      avatar: GameData.avatar,
      onboardingSeen: GameData.onboardingSeen,
    );

    // Migrate to Hive
    await saveProfile(profile);
    
    return profile;
  }

  @override
  Future<void> saveProfile(PlayerProfile profile) async {
    final data = {
      'stars': profile.stars,
      'coins': profile.coins,
      'level': profile.level,
      'streak': profile.streak,
      'totalCorrect': profile.totalCorrect,
      'totalWrong': profile.totalWrong,
      'childName': profile.childName,
      'childAge': profile.childAge,
      'avatar': profile.avatar,
      'onboardingSeen': profile.onboardingSeen,
    };
    await _localDataSource.savePlayerData(data);
    
    // Also update legacy GameData for compatibility during transition
    GameData.stars = profile.stars;
    GameData.coins = profile.coins;
    GameData.level = profile.level;
    GameData.streak = profile.streak;
    GameData.totalCorrect = profile.totalCorrect;
    GameData.totalWrong = profile.totalWrong;
    GameData.childName = profile.childName;
    GameData.childAge = profile.childAge;
    GameData.avatar = profile.avatar;
    GameData.onboardingSeen = profile.onboardingSeen;
    await GameData.save();
  }

  @override
  Future<void> updateStars(int amount) async {
    final profile = await getProfile();
    await saveProfile(profile.copyWith(stars: profile.stars + amount));
  }

  @override
  Future<void> updateCoins(int amount) async {
    final profile = await getProfile();
    final newCoins = profile.coins + amount;
    final newLevel = (newCoins ~/ 100) + 1;
    await saveProfile(profile.copyWith(coins: newCoins, level: newLevel));
  }
}
