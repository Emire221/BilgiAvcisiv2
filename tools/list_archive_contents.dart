/// Tar.bz2 arşiv içeriğini listele
///
/// Bu araç, bir tar.bz2 arşivinin içeriğini listeler ve manifest güncellemesi için
/// gerekli dosya bilgilerini gösterir.
///
/// Kullanım: dart tools/list_archive_contents.dart `arsiv_yolu`

import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Kullanım: dart tools/list_archive_contents.dart <arsiv_yolu>');
    print(
      'Örnek: dart tools/list_archive_contents.dart storage/3_Sinif/3_Sinif_v1.tar.bz2',
    );
    exit(1);
  }

  final archivePath = args[0];
  final archiveFile = File(archivePath);

  if (!await archiveFile.exists()) {
    print('Hata: Arşiv bulunamadı: $archivePath');
    exit(1);
  }

  print('Arşiv içeriği analiz ediliyor: $archivePath\n');

  try {
    // Arşivi oku ve aç
    final bytes = await archiveFile.readAsBytes();
    final decompressed = BZip2Decoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(decompressed);

    print('═══════════════════════════════════════════════════════════');
    print('ARŞİV İÇERİĞİ');
    print('═══════════════════════════════════════════════════════════\n');

    final jsonFiles = <ArchiveFile>[];
    final otherFiles = <ArchiveFile>[];

    // Dosyaları kategorize et
    for (var file in archive.files) {
      if (file.isFile) {
        if (file.name.endsWith('.json')) {
          jsonFiles.add(file);
        } else {
          otherFiles.add(file);
        }
      }
    }

    // JSON dosyalarını listele
    print('📋 JSON DOSYALARI (${jsonFiles.length} adet):');
    print('───────────────────────────────────────────────────────────');

    int testCount = 0;
    int flashcardCount = 0;
    int otherJsonCount = 0;

    for (var file in jsonFiles) {
      final content = utf8.decode(file.content as List<int>);
      final hash = md5.convert(file.content as List<int>).toString();

      try {
        final json = jsonDecode(content);
        String type = 'Bilinmeyen';

        if (json is Map<String, dynamic>) {
          if (json.containsKey('testID')) {
            type = 'TEST';
            testCount++;
          } else if (json.containsKey('kartSetID')) {
            type = 'BİLGİ KARTI';
            flashcardCount++;
          } else if (json.containsKey('dersler')) {
            type = 'DERS LİSTESİ';
            otherJsonCount++;
          } else if (json.containsKey('konular')) {
            type = 'KONU LİSTESİ';
            otherJsonCount++;
          } else if (json.containsKey('videolar')) {
            type = 'VİDEO LİSTESİ';
            otherJsonCount++;
          } else {
            otherJsonCount++;
          }
        }

        print('  ${file.name}');
        print('    Tür: $type');
        print('    Boyut: ${file.size} bytes');
        print('    Hash: ${hash.substring(0, 8)}...');
        print('');
      } catch (e) {
        print('  ${file.name} [HATA: Ayrıştırılamadı]');
        print('');
      }
    }

    print('═══════════════════════════════════════════════════════════');
    print('ÖZET');
    print('═══════════════════════════════════════════════════════════');
    print('  Toplam JSON: ${jsonFiles.length}');
    print('  - Testler: $testCount');
    print('  - Bilgi Kartları: $flashcardCount');
    print('  - Diğer (liste dosyaları): $otherJsonCount');

    if (otherFiles.isNotEmpty) {
      print('  Diğer dosyalar: ${otherFiles.length}');
    }

    print('\n💡 Manifest Güncelleme Önerisi:');
    print('═══════════════════════════════════════════════════════════');
    print('manifest.json dosyanızda şu dosyaları ekleyin:\n');

    final manifestEntries = <Map<String, dynamic>>[];
    for (var file in jsonFiles) {
      final hash = md5.convert(file.content as List<int>).toString();
      manifestEntries.add({
        'path': '3_Sinif/${file.name}',
        'type': 'json',
        'version': 'v1',
        'hash': hash,
        'addedAt': DateTime.now().toIso8601String(),
      });
    }

    final manifestJson = JsonEncoder.withIndent('  ').convert(manifestEntries);
    print(manifestJson);
  } catch (e) {
    print('Hata: Arşiv açılırken bir sorun oluştu: $e');
    exit(1);
  }
}
