import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/mascot_repository.dart';
import '../../data/repositories/mascot_repository_impl.dart';
import '../../../../services/database_helper.dart';
import '../../domain/entities/mascot.dart';

/// MascotRepository provider
final mascotRepositoryProvider = Provider<MascotRepository>((ref) {
  return MascotRepositoryImpl(DatabaseHelper());
});

/// Aktif maskot provider
final activeMascotProvider = FutureProvider<Mascot?>((ref) async {
  final repository = ref.watch(mascotRepositoryProvider);
  return await repository.getUserMascot();
});

/// Maskot var mı kontrolü
final hasMascotProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(mascotRepositoryProvider);
  return await repository.hasMascot();
});
