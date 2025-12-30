import '../models/manifest_model.dart';

/// Senkronizasyon işlemlerini soyutlayan repository interface
abstract class SyncRepository {
  /// Manifest dosyasını Firebase Storage'dan indirir
  Future<Manifest> downloadManifest();

  /// Tek bir dosyayı indirir (zip veya json)
  Future<List<int>> downloadFile(String path);

  /// Zip dosyasını aç ve içeriğini döndür
  Future<Map<String, List<int>>> extractZipFile(List<int> zipData);

  /// Yerel DB'de kayıtlı dosya listesini getirir
  Future<List<String>> getLocalFileList();

  /// Dosyayı yerel DB'ye kaydet
  Future<void> saveFileToLocal(String path, List<int> data);

  /// Dosya hash'ini hesapla
  String calculateHash(List<int> data);
}
