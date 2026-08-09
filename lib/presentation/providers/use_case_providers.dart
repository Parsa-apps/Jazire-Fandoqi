import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/player_repository_provider.dart';
import '../../domain/usecases/complete_stage.dart';
import '../../domain/usecases/get_player_profile.dart';
import '../../domain/usecases/record_answer.dart';
import '../../domain/usecases/update_settings.dart';

/// ────────────────────────────────────────────────────────────
/// 🏛️ فاز ۲: تزریق UseCaseهای لایه Domain به اپ از طریق Riverpod
/// صفحه‌ها فقط این Providerها را می‌خوانند و هرگز مستقیم با
/// SharedPreferences/Hive درگیر نمی‌شوند.
/// ────────────────────────────────────────────────────────────

final getPlayerProfileProvider = Provider<GetPlayerProfile>((ref) {
  return GetPlayerProfile(ref.watch(playerRepositoryProvider));
});

final recordAnswerProvider = Provider<RecordAnswer>((ref) {
  return const RecordAnswer();
});

final completeStageProvider = Provider<CompleteStage>((ref) {
  return const CompleteStage();
});

final updateSettingsProvider = Provider<UpdateSettings>((ref) {
  return const UpdateSettings();
});
