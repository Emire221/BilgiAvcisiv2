# 🛠️ Bilgi Avcısı - Tools Klasörü

<p align="center">
  <strong>Geliştirici Araçları ve Yardımcı Scriptler</strong>
</p>

---

## 📋 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Araçlar](#-araçlar)
- [Kullanım](#-kullanım)
- [Yapılandırma](#-yapılandırma)

---

## 🎯 Genel Bakış

Bu klasör, Bilgi Avcısı projesinin geliştirme sürecinde kullanılan yardımcı araçları ve scriptleri içerir.

### Klasör Yapısı

```
tools/
├── README.md                    # Bu dosya
├── analysis_options.yaml        # Araçlar için analiz kuralları
├── generate_manifest.dart       # İçerik manifest üretici
├── list_archive_contents.dart   # Arşiv içerik listeci
└── example_manifest.json        # Örnek manifest formatı
```

---

## 🔧 Araçlar

### 1. generate_manifest.dart

Firebase Storage'dan indirilen içerik paketleri için manifest dosyası üreten araç.

#### Özellikler

- ZIP arşivlerini okur
- Dosya hash'lerini hesaplar (MD5/SHA256)
- JSON formatında manifest üretir
- İçerik versiyonlama desteği

#### Çalıştırma

```bash
cd tools
dart run generate_manifest.dart <archive_path> [output_path]
```

#### Örnek Kullanım

```bash
# Tek arşiv için manifest oluştur
dart run generate_manifest.dart ../assets/content.zip manifest.json

# Varsayılan çıktı ile
dart run generate_manifest.dart ../assets/content.zip
# Çıktı: ../assets/content_manifest.json
```

#### Çıktı Formatı

```json
{
  "version": "1.0.0",
  "generated": "2026-01-10T12:00:00Z",
  "files": [
    {
      "path": "data/tests.json",
      "size": 12345,
      "hash": "abc123...",
      "hashAlgorithm": "sha256"
    }
  ],
  "totalFiles": 10,
  "totalSize": 123456
}
```

---

### 2. list_archive_contents.dart

ZIP arşivlerinin içeriğini listeleyen yardımcı araç.

#### Özellikler

- Arşiv içeriğini hiyerarşik gösterir
- Dosya boyutlarını formatlar
- Toplam dosya/klasör sayısı
- Sıkıştırma oranı hesaplama

#### Çalıştırma

```bash
cd tools
dart run list_archive_contents.dart <archive_path>
```

#### Örnek Kullanım

```bash
dart run list_archive_contents.dart ../assets/content.zip
```

#### Örnek Çıktı

```
📦 content.zip
├── 📁 data/
│   ├── 📄 tests.json (12.3 KB)
│   ├── 📄 flashcards.json (8.5 KB)
│   └── 📄 topics.json (3.2 KB)
├── 📁 images/
│   ├── 🖼️ logo.png (45.6 KB)
│   └── 🖼️ background.jpg (120.0 KB)
└── 📄 manifest.json (1.2 KB)

📊 Özet:
   Toplam Dosya: 6
   Toplam Klasör: 2
   Toplam Boyut: 191.8 KB
   Sıkıştırma Oranı: %65
```

---

### 3. example_manifest.json

İçerik manifest dosyasının şemasını gösteren örnek dosya.

#### Şema

```json
{
  "$schema": "https://bilgiavcisi.com/schemas/manifest-v1.json",
  "version": "1.0.0",
  "name": "Bilgi Avcısı İçerik Paketi",
  "description": "Ders, test ve flashcard içerikleri",
  "generated": "2026-01-10T12:00:00.000Z",
  "generator": {
    "name": "generate_manifest.dart",
    "version": "1.0.0"
  },
  "content": {
    "lessons": {
      "count": 8,
      "path": "data/lessons/"
    },
    "topics": {
      "count": 45,
      "path": "data/topics/"
    },
    "tests": {
      "count": 120,
      "path": "data/tests/"
    },
    "flashcards": {
      "count": 80,
      "path": "data/flashcards/"
    }
  },
  "files": [
    {
      "path": "data/lessons.json",
      "size": 5432,
      "hash": "sha256:abc123...",
      "modified": "2026-01-10T10:00:00.000Z"
    }
  ],
  "metadata": {
    "totalFiles": 15,
    "totalSize": 256000,
    "compressedSize": 98000,
    "compressionRatio": 0.62
  }
}
```

---

### 4. analysis_options.yaml

Tools klasörü için özel lint kuralları.

```yaml
# Tools için analiz seçenekleri
include: package:lints/recommended.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
  
  language:
    strict-casts: true
    strict-inference: true

linter:
  rules:
    - avoid_print: false  # CLI araçlarında print kullanılabilir
    - prefer_single_quotes
    - prefer_final_locals
    - sort_constructors_first
```

---

## 📖 Kullanım

### Ön Gereksinimler

```bash
# Dart SDK yüklü olmalı
dart --version

# Gerekli paketler (pubspec.yaml'da tanımlı)
# - crypto: Hash hesaplama
# - archive: ZIP işlemleri
```

### Temel Komutlar

```bash
# Tools klasörüne git
cd tools

# Manifest oluştur
dart run generate_manifest.dart <input.zip> [output.json]

# Arşiv içeriğini listele
dart run list_archive_contents.dart <archive.zip>

# Analiz çalıştır (tools klasörü için)
dart analyze .
```

---

## ⚙️ Yapılandırma

### Ortam Değişkenleri

| Değişken | Açıklama | Varsayılan |
|----------|----------|------------|
| `MANIFEST_VERSION` | Manifest versiyonu | "1.0.0" |
| `HASH_ALGORITHM` | Hash algoritması | "sha256" |
| `OUTPUT_DIR` | Çıktı klasörü | "." |

### Örnek .env

```env
MANIFEST_VERSION=1.0.0
HASH_ALGORITHM=sha256
OUTPUT_DIR=./output
```

---

## 🔄 Geliştirme

### Yeni Araç Ekleme

1. `tools/` klasörüne yeni `.dart` dosyası oluşturun
2. Gerekli importları ekleyin
3. `main()` fonksiyonunu tanımlayın
4. Bu README'ye dokümantasyon ekleyin

### Araç Şablonu

```dart
// tools/my_new_tool.dart

import 'dart:io';

/// Araç açıklaması
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Kullanım: dart run my_new_tool.dart <arg>');
    exit(1);
  }

  try {
    // İşlemler
    print('✅ Başarılı!');
  } catch (e) {
    print('❌ Hata: $e');
    exit(1);
  }
}
```

---

## 📊 Araç Kullanım İstatistikleri

| Araç | Son Çalıştırma | Başarı Oranı |
|------|----------------|--------------|
| generate_manifest | - | - |
| list_archive_contents | - | - |

---

## 🐛 Sorun Giderme

### Yaygın Hatalar

#### "Archive paketi bulunamadı"

```bash
# Çözüm: pubspec.yaml'da archive paketini kontrol edin
flutter pub get
```

#### "Dosya bulunamadı"

```bash
# Çözüm: Doğru yol kullandığınızdan emin olun
# Mutlak veya göreceli yol kullanın
dart run generate_manifest.dart /full/path/to/archive.zip
```

#### "İzin hatası"

```bash
# Çözüm: Dosya izinlerini kontrol edin
chmod +r archive.zip
chmod +w output/
```

---

## 📝 Changelog

### v1.0.0 (10 Ocak 2026)

- İlk sürüm
- generate_manifest.dart eklendi
- list_archive_contents.dart eklendi
- Örnek manifest dosyası eklendi

---

## 📄 Lisans

Bu araçlar Bilgi Avcısı projesinin bir parçasıdır. Tüm hakları saklıdır.

---

**Son Güncelleme:** 10 Ocak 2026
