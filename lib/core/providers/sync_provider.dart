import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/sync/domain/models/manifest_model.dart';
import '../../features/sync/presentation/controllers/sync_controller.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/local_preferences_service.dart';
import '../../services/database_helper.dart';

/// SyncController provider
final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>(
  (ref) {
    return SyncController(
      storageService: FirebaseStorageService(),
      prefsService: LocalPreferencesService(),
      dbHelper: DatabaseHelper(),
    );
  },
);

/// Sync durumu provider (sadece okunabilir)
final syncStateProvider = Provider<SyncState>((ref) {
  return ref.watch(syncControllerProvider);
});

/// Sync progress provider
final syncProgressProvider = Provider<double>((ref) {
  return ref.watch(syncControllerProvider).progress;
});

/// Sync mesaj provider
final syncMessageProvider = Provider<String>((ref) {
  return ref.watch(syncControllerProvider).message;
});
