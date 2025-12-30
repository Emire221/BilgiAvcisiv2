import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/manifest_model.dart';
import '../../../../services/firebase_storage_service.dart';
import '../../../../services/local_preferences_service.dart';
import '../../../../services/database_helper.dart';

/// Senkronizasyon kontrolcüsü - Manifest tabanlı sync sistemi
class SyncController extends StateNotifier<SyncState> {
  final FirebaseStorageService _storageService;
  final LocalPreferencesService _prefsService;
  // ignore: unused_field
  final DatabaseHelper _dbHelper;

  // 🎯 Eğlenceli yükleme mesajları - her aşama için farklı
  static const List<String> _manifestMessages = [
    '🗺️ Hazine haritası aranıyor...',
    '📜 Büyülü parşömen açılıyor...',
    '🔮 Kristal küre okunuyor...',
  ];

  static const List<String> _firstRunMessages = [
    '🏰 Bilgi kalesi inşa ediliyor...',
    '✨ Sihirli dünya kuruluyor...',
    '🌈 Gökkuşağı köprüsü yapılıyor...',
  ];

  static const List<String> _downloadMessages = [
    '🚀 Uzay gemisi içerik topluyor...',
    '🧲 Bilgi mıknatısı çalışıyor...',
    '🎣 Bilgi balıkları yakalanıyor...',
    '🌟 Yıldız tozu serpiliyor...',
    '🎪 Eğlence çadırı kuruluyor...',
    '🦋 Bilgi kelebekleri uçuşuyor...',
    '🍪 Bilgi kurabiyeleri pişiyor...',
    '🎨 Renkli dünyalar boyanıyor...',
    '🎭 Eğlence maskeleri takılıyor...',
    '🎸 Rock yıldızı sahneye çıkıyor...',
  ];

  static const List<String> _updateMessages = [
    '🔍 Dedektif yeni ipuçları arıyor...',
    '🕵️ Gizli güncellemeler keşfediliyor...',
    '🔭 Uzaydan yeni sinyaller geliyor...',
  ];

  static const List<String> _completeMessages = [
    '🎉 Süper! Her şey hazır!',
    '🏆 Tebrikler! Macera başlıyor!',
    '⭐ Harika! Yıldız gibi parlıyorsun!',
    '🦸 Süper kahraman modu aktif!',
  ];

  int _messageIndex = 0;

  String _getRandomMessage(List<String> messages) {
    return messages[_messageIndex++ % messages.length];
  }

  SyncController({
    required FirebaseStorageService storageService,
    required LocalPreferencesService prefsService,
    required DatabaseHelper dbHelper,
  }) : _storageService = storageService,
       _prefsService = prefsService,
       _dbHelper = dbHelper,
       super(const SyncState());

  /// Ana senkronizasyon metodu
  Future<void> syncContent(String className) async {
    try {
      _messageIndex = DateTime.now().millisecond; // Rastgele başlangıç
      state = state.copyWith(
        isSyncing: true,
        progress: 0.0,
        message: '🚀 Motor çalıştırılıyor...',
        error: null,
      );

      // 1. Manifest'i indir
      state = state.copyWith(message: _getRandomMessage(_manifestMessages));
      final manifest = await _downloadManifest(className);

      // 2. İlk çalıştırma kontrolü
      final isFirstRun = await _prefsService.isFirstRun();

      if (isFirstRun) {
        await _handleFirstRun(className, manifest);
      } else {
        await _handleIncrementalSync(className, manifest);
      }

      // 3. Son sync bilgilerini kaydet
      await _prefsService.setLastSyncVersion(manifest.version);
      await _prefsService.setLastSyncDate(DateTime.now());
      await _prefsService.setFirstRunComplete();

      state = state.copyWith(
        isSyncing: false,
        progress: 1.0,
        message: _getRandomMessage(_completeMessages),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Sync hatası: $e');
      state = state.copyWith(
        isSyncing: false,
        error: 'Senkronizasyon hatası: $e',
        message: '😔 Hay aksi! Bir sorun oldu...',
      );
    }
  }

  /// Manifest dosyasını indir ve parse et
  Future<Manifest> _downloadManifest(String className) async {
    try {
      return await _storageService.downloadManifest(className);
    } catch (e) {
      throw Exception('Manifest indirilemedi: $e');
    }
  }

  /// İlk çalıştırma - Tüm içeriği indir
  Future<void> _handleFirstRun(String className, Manifest manifest) async {
    state = state.copyWith(message: _getRandomMessage(_firstRunMessages));

    // Sınıfa ait dosyaları filtrele
    final classFiles = manifest.files
        .where((file) => file.path.startsWith(className))
        .toList();

    // Önce tar.bz2 arşiv dosyaları, sonra json dosyaları
    final archiveFiles = classFiles.where((f) => f.type == 'tar.bz2').toList();
    final jsonFiles = classFiles.where((f) => f.type == 'json').toList();

    final totalFiles = archiveFiles.length + jsonFiles.length;
    int downloadedCount = 0;

    // tar.bz2 arşiv dosyalarını indir
    for (final file in archiveFiles) {
      try {
        state = state.copyWith(
          currentFile: file.path,
          message: _getRandomMessage(_downloadMessages),
          progress: downloadedCount / totalFiles,
        );

        await _downloadAndProcessFile(file, className);
        downloadedCount++;

        state = state.copyWith(
          downloadedFiles: [...state.downloadedFiles, file.path],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Dosya indirme hatası (${file.path}): $e');
        state = state.copyWith(failedFiles: [...state.failedFiles, file.path]);
      }
    }

    // JSON dosyalarını indir (arşiv yoksa)
    for (final file in jsonFiles) {
      try {
        state = state.copyWith(
          currentFile: file.path,
          message: _getRandomMessage(_downloadMessages),
          progress: downloadedCount / totalFiles,
        );

        await _downloadAndProcessFile(file, className);
        downloadedCount++;

        state = state.copyWith(
          downloadedFiles: [...state.downloadedFiles, file.path],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Dosya indirme hatası (${file.path}): $e');
        state = state.copyWith(failedFiles: [...state.failedFiles, file.path]);
      }
    }
  }

  /// İnkremental sync - Sadece yeni dosyaları indir
  Future<void> _handleIncrementalSync(
    String className,
    Manifest manifest,
  ) async {
    state = state.copyWith(message: _getRandomMessage(_updateMessages));

    // Yerel versiyonu al
    final localVersion = await _prefsService.getLastSyncVersion();

    if (localVersion == manifest.version) {
      state = state.copyWith(
        message: '✨ Her şey güncel! Hazırsın!',
        progress: 1.0,
      );
      return;
    }

    // Yerel dosya listesini al
    final localFiles = await _getLocalFileList();

    // Sınıfa ait yeni dosyaları filtrele
    final newFiles = manifest.files
        .where(
          (file) =>
              file.path.startsWith(className) &&
              !localFiles.contains(file.path),
        )
        .toList();

    if (newFiles.isEmpty) {
      state = state.copyWith(
        message: '🎯 Süper! Yeni bir şey yok!',
        progress: 1.0,
      );
      return;
    }

    // Önce tar.bz2, sonra json
    final archiveFiles = newFiles.where((f) => f.type == 'tar.bz2').toList();
    final jsonFiles = newFiles.where((f) => f.type == 'json').toList();

    final totalFiles = archiveFiles.length + jsonFiles.length;
    int downloadedCount = 0;

    state = state.copyWith(
      message: '🎁 Vay! $totalFiles yeni sürpriz bulundu!',
    );

    // tar.bz2 arşiv dosyalarını indir
    for (final file in archiveFiles) {
      try {
        state = state.copyWith(
          currentFile: file.path,
          message: _getRandomMessage(_downloadMessages),
          progress: downloadedCount / totalFiles,
        );

        await _downloadAndProcessFile(file, className);
        downloadedCount++;

        state = state.copyWith(
          downloadedFiles: [...state.downloadedFiles, file.path],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Dosya indirme hatası (${file.path}): $e');
        state = state.copyWith(failedFiles: [...state.failedFiles, file.path]);
      }
    }

    // JSON dosyalarını indir
    for (final file in jsonFiles) {
      try {
        state = state.copyWith(
          currentFile: file.path,
          message: _getRandomMessage(_downloadMessages),
          progress: downloadedCount / totalFiles,
        );

        await _downloadAndProcessFile(file, className);
        downloadedCount++;

        state = state.copyWith(
          downloadedFiles: [...state.downloadedFiles, file.path],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Dosya indirme hatası (${file.path}): $e');
        state = state.copyWith(failedFiles: [...state.failedFiles, file.path]);
      }
    }
  }

  /// Dosyayı indir ve işle
  Future<void> _downloadAndProcessFile(
    ManifestFile file,
    String className,
  ) async {
    if (file.type == 'tar.bz2') {
      // Hedef klasör yolunu hazırla
      final docDir = await getApplicationDocumentsDirectory();
      // Sınıf ismini güvenli hale getir (Örn: "3. Sınıf" -> "3_Sinif")
      final safeClassName = className
          .replaceAll('.', '')
          .replaceAll(' ', '_');
      final targetPath = '${docDir.path}/$safeClassName';

      // tar.bz2 arşivini indir ve AÇIKLAMA: Arşiv zaten {safeClassName} klasörünü içerdiği için
      // root (docDir) dizinine çıkartıyoruz. Böylece .../3_Sinif/3_Sinif/... oluşmuyor.
      await _storageService.downloadAndExtractArchive(
        file.path,
        (message) {
          state = state.copyWith(message: message);
        },
        destinationPath: docDir.path,
      );

      // Arşiv içeriğini veritabanına kaydet
      try {
        await _storageService.processLocalArchiveContent(targetPath, (message) {
          state = state.copyWith(message: message);
        });
      } catch (e) {
        if (kDebugMode) debugPrint('Arşiv içerik işleme hatası: $e');
        // Kritik hata değilse devam et, ama logla
      }
    } else {
      // JSON dosyasını indir ve DB'ye kaydet
      await _storageService.downloadAndProcessJson(file.path, (message) {
        state = state.copyWith(message: message);
      });
    }

    // İndirme başarılı, veritabanına kaydet
    await _dbHelper.addDownloadedFile(file.path);
  }

  /// Yerel dosya listesini al
  Future<List<String>> _getLocalFileList() async {
    return await _dbHelper.getDownloadedFiles();
  }

  /// Sync'i iptal et
  void cancelSync() {
    state = const SyncState();
  }
}
