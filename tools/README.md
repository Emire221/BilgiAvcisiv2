# Manifest ve Arşiv Yönetim Araçları

**Son Güncelleme:** 5 Aralık 2025  
**Versiyon:** v1.4.0

Bu klasörde, Firebase Storage'daki dosyalarınızı yönetmek için yardımcı araçlar bulunur.

## 1. Arşiv İçeriği Analiz Aracı

**Amaç:** Bir tar.bz2 arşivinin içeriğini analiz eder ve manifest için gerekli bilgileri gösterir.

**Kullanım:**
```bash
dart tools/list_archive_contents.dart <arsiv_yolu>
```

**Örnek:**
```bash
dart tools/list_archive_contents.dart storage/3_Sinif/3_Sinif_v1.tar.bz2
```

**Çıktı:**
- Arşiv içindeki tüm JSON dosyalarının listesi
- Her dosyanın türü (Test, Bilgi Kartı, vb.)
- Dosya boyutları ve hash değerleri
- Manifest için hazır JSON çıktısı

## 2. Manifest Oluşturma Aracı

**Amaç:** Bir klasördeki tüm dosyalar için otomatik olarak manifest.json dosyası oluşturur.

**Kullanım:**
```bash
dart tools/generate_manifest.dart <klasor_yolu>
```

**Örnek:**
```bash
dart tools/generate_manifest.dart storage/3_Sinif
```

**Çıktı:**
- Klasördeki tüm .json ve .tar.bz2 dosyaları için manifest.json oluşturulur
- Her dosya için hash değerleri otomatik hesaplanır

## 3. Örnek Manifest Dosyası

`example_manifest.json` dosyası, manifest.json formatının bir örneğidir. Kendi dosyalarınız için şablon olarak kullanabilirsiniz.

## Önemli Notlar

### Arşiv Yapısı

3_Sinif_v1.tar.bz2 arşivi şu yapıda olmalıdır:

```
3_Sinif_v1.tar.bz2/
├── derslistesi.json
├── konulistesi.json
├── konuvideo.json
├── test_1.json          # testID alanı içermeli
├── test_2.json          # testID alanı içermeli
├── test_matematik_1.json
├── bilgikart_1.json     # kartSetID alanı içermeli
├── bilgikart_2.json     # kartSetID alanı içermeli
├── level_001.json       # levelID alanı içermeli (Cümle Tamamlama)
├── guess_001.json       # guessID alanı içermeli (Salla Bakalım)
└── ... (diğer test ve bilgi kartı dosyaları)
```

**Desteklenen ID Tipleri:**
| ID Alanı | Oyun/İçerik | Tablo |
|----------|-------------|-------|
| testID | Test | Testler |
| kartSetID | Bilgi Kartı | BilgiKartlari |
| levelID | Cümle Tamamlama | FillBlanksLevels |
| guessID | Salla Bakalım | GuessLevels |

> **Not (v1.4.0):** `arenaSetID` artık desteklenmiyor. Arena sistemi kaldırıldı ve yerine 1v1 Düello sistemi geldi.

**ÖNEMLİ:** Tüm JSON dosyaları doğrudan arşivin kök dizininde olmalıdır. Alt klasör kullanmayın!

### Manifest Güncelleme

Manifest.json dosyanızda, **sadece** tar.bz2 arşiv dosyasını ve temel JSON dosyalarını (derslistesi, konulistesi, konuvideo) listelemeniz yeterlidir. Arşiv içindeki test ve bilgi kartı dosyaları otomatik olarak algılanacaktır.

Ancak eğer isterseniz, arşiv içindeki her dosyayı ayrı ayrı da listeleyebilirsiniz:

```json
{
  "version": "1.0.0",
  "updatedAt": "2025-12-05T10:00:00.000Z",
  "files": [
    {
      "path": "3_Sinif/3_Sinif_v1.tar.bz2",
      "type": "tar.bz2",
      "version": "v1",
      "hash": "gerçek_hash_değeri",
      "addedAt": "2025-12-05T10:00:00.000Z"
    },
    {
      "path": "3_Sinif/derslistesi.json",
      "type": "json",
      "version": "v1",
      "hash": "gerçek_hash_değeri",
      "addedAt": "2025-12-05T10:00:00.000Z"
    }
  ]
}
```

### Hash Hesaplama

Hash değerleri, dosya bütünlüğünü kontrol etmek için kullanılır. MD5 hash kullanılır.

Bir dosyanın hash'ini hesaplamak için:

**Windows PowerShell:**
```powershell
Get-FileHash -Algorithm MD5 dosya.json | Select-Object Hash
```

**Linux/Mac:**
```bash
md5sum dosya.json
```

Ya da yukarıdaki Dart araçlarını kullanın - otomatik hesaplarlar.

## Sorun Giderme

### "Dosyalar veritabanına eklenmiyor"

1. `list_archive_contents.dart` ile arşiv içeriğini kontrol edin
2. Tüm test dosyalarının `testID` alanı içerdiğinden emin olun
3. Tüm bilgi kartı dosyalarının `kartSetID` alanı içerdiğinden emin olun
4. Cümle tamamlama için `levelID` alanı olmalı
5. Salla Bakalım için `guessID` alanı olmalı

### "Arşiv açılmıyor"

1. Dosyanın gerçekten tar.bz2 formatında olduğundan emin olun
2. Dosyanın bozuk olmadığını kontrol edin
3. Arşiv adının `.tar.bz2` uzantısıyla bittiğinden emin olun

### "Manifest hatası"

1. JSON formatının doğru olduğundan emin olun
2. Tüm gerekli alanların (`version`, `updatedAt`, `files`) bulunduğundan emin olun
3. Tarih formatlarının ISO 8601 standardında olduğundan emin olun

---

## v1.4.0 Değişiklikleri

- ❌ `arenaSetID` desteği kaldırıldı (Arena sistemi kaldırıldı)
- ✅ 1v1 Düello sistemi eklendi (ayrı JSON dosyası gerektirmez)
- ✅ Mevcut `testID` ve `levelID` içerikleri düello için de kullanılır

---

**Son Güncelleme:** 5 Aralık 2025  
**Versiyon:** v1.4.0
