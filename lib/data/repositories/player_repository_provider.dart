import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/local_data_source.dart';
import 'player_repository_impl.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return HiveLocalDataSource();
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return PlayerRepositoryImpl(localDataSource);
});
