import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_profile.dart';
import '../../data/repositories/player_repository_provider.dart';

class PlayerProfileNotifier extends StateNotifier<AsyncValue<PlayerProfile>> {
  final Ref _ref;

  PlayerProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(playerRepositoryProvider);
      final profile = await repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addStars(int amount) async {
    final repository = _ref.read(playerRepositoryProvider);
    await repository.updateStars(amount);
    // Reload profile to update state
    await loadProfile();
  }

  Future<void> addCoins(int amount) async {
    final repository = _ref.read(playerRepositoryProvider);
    await repository.updateCoins(amount);
    await loadProfile();
  }
}

final playerProfileProvider = StateNotifierProvider<PlayerProfileNotifier, AsyncValue<PlayerProfile>>((ref) {
  return PlayerProfileNotifier(ref);
});
