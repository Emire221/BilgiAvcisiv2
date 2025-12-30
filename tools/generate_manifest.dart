/// Manifest.json oluşturucu
///
/// Bu araç, Firebase Storage'da yüklü dosyalar için manifest.json dosyası oluşturur.
///
/// Kullanım:
///   dart tools/generate_manifest.dart <klasor_yolu> [hedef_klasor_adi]
///
/// Örnekler:
///   dart tools/generate_manifest.dart C:\Users\ahmet\Desktop\storage 3_Sinif
///   dart tools/generate_manifest.dart ./storage 3_Sinif
///
/// Eğer hedef_klasor_adi verilmezse, .tar.bz2 dosyasının adından otomatik algılanır.
/// Örnek: 3_Sinif.tar.bz2 -> hedef klasör: 3_Sinif

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Kullanım: dart tools/generate_manifest.dart <klasor_yolu> [hedef_klasor_adi]');
    print('');
    print('Örnekler:');
    print('  dart tools/generate_manifest.dart C:\\Users\\ahmet\\Desktop\\storage 3_Sinif');
    print('  dart tools/generate_manifest.dart ./storage 3_Sinif');
    print('');
    print('Eğer hedef_klasor_adi verilmezse, .tar.bz2 dosyasının adından otomatik algılanır.');
    exit(1);
  }

  final folderPath = args[0];
  final folder = Directory(folderPath);

  if (!await folder.exists()) {
    print('Hata: Klasör bulunamadı: $folderPath');
    exit(1);
  }

  // Hedef klasör adını al veya otomatik algıla
  String? targetFolder = args.length > 1 ? args[1] : null;

  print('Manifest oluşturuluyor: $folderPath');

  final manifest = await generateManifest(folder, targetFolder);
  final manifestJson = JsonEncoder.withIndent('  ').convert(manifest);

  final manifestFile = File(path.join(folderPath, 'manifest.json'));
  await manifestFile.writeAsString(manifestJson);

  print('✓ Manifest oluşturuldu: ${manifestFile.path}');
  print('  Toplam dosya: ${manifest['files'].length}');
  print('  Hedef klasör: ${manifest['_targetFolder'] ?? 'Algılanamadı'}');
}

Future<Map<String, dynamic>> generateManifest(Directory folder, String? targetFolder) async {
  final files = <Map<String, dynamic>>[];
  String? detectedTargetFolder = targetFolder;

  // Tüm dosyaları tara
  await for (var entity in folder.list(recursive: false)) {
    if (entity is File) {
      final fileName = path.basename(entity.path);

      // Dosya tipini belirle
      String fileType;
      if (fileName.endsWith('.tar.bz2')) {
        fileType = 'tar.bz2';
        
        // Hedef klasör adı verilmemişse, .tar.bz2 dosyasının adından algıla
        // Örnek: 3_Sinif.tar.bz2 -> 3_Sinif
        if (detectedTargetFolder == null) {
          detectedTargetFolder = fileName.replaceAll('.tar.bz2', '');
          print('  Hedef klasör otomatik algılandı: $detectedTargetFolder');
        }
      } else if (fileName.endsWith('.json')) {
        fileType = 'json';
      } else {
        continue; // Diğer dosyaları atla
      }

      // Dosya hash'ini hesapla
      final bytes = await entity.readAsBytes();
      final hash = md5.convert(bytes).toString();

      // Firebase Storage'daki yol: hedefKlasör/dosyaAdı
      final storagePath = detectedTargetFolder != null 
          ? '$detectedTargetFolder/$fileName'
          : fileName;

      files.add({
        'path': storagePath,
        'type': fileType,
        'version': 'v1',
        'hash': hash,
        'addedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // Eğer hedef klasör algılanamadıysa uyar
  if (detectedTargetFolder == null) {
    print('⚠️ Uyarı: Hedef klasör adı algılanamadı. Lütfen ikinci parametre olarak belirtin.');
    print('   Örnek: dart tools/generate_manifest.dart ./storage 3_Sinif');
  }

  return {
    'version': '1.0.0',
    'updatedAt': DateTime.now().toIso8601String(),
    'files': files,
  };
}
