import '../entities/player_profile.dart';

abstract class PlayerRepository {
  Future<PlayerProfile> getProfile();
  Future<void> saveProfile(PlayerProfile profile);
  Future<void> updateStars(int amount);
  Future<void> updateCoins(int amount);
  // Add other methods as needed
}
