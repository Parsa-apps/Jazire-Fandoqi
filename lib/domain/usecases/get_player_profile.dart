import '../entities/player_profile.dart';
import '../repositories/player_repository.dart';

/// دریافت پروفایل بازیکن از لایه داده.
///
/// UseCase خالص لایه Domain: هیچ دانشی از Flutter یا SharedPreferences/Hive
/// ندارد و فقط از [PlayerRepository] استفاده می‌کند. در تست می‌توان
/// ریپازیتوری ساختگی (Mock) به آن داد.
class GetPlayerProfile {
  final PlayerRepository _repository;

  GetPlayerProfile(this._repository);

  Future<PlayerProfile> call() => _repository.getProfile();
}
