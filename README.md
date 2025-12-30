# BİLGİ AVCISI 🎓

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-37%20Passing-success)](./test)
[![Quality](https://img.shields.io/badge/Analysis-No%20Issues-success)](./analyze_output.txt)
[![License](https://img.shields.io/badge/License-Private-red)]()

**BİLGİ AVCISI**, Türk öğrenciler için geliştirilmiş kapsamlı bir mobil eğitim platformudur. Sınıf bazlı içerik, interaktif testler, bilgi kartları ve gamification özellikleriyle öğrenmeyi kolaylaştırır.

---

## 📋 İçindekiler

- [Özellikler](#-özellikler)
- [Ekranlar](#-ekranlar)
- [Teknoloji Stack](#-teknoloji-stack)
- [Mimari](#-mimari)
- [Kurulum](#-kurulum)
- [Proje Yapısı](#-proje-yapısı)
- [Sync Sistemi](#-sync-sistemi)
- [Testler](#-testler)
- [Son Güncellemeler](#-son-güncellemeler)

---

## ✨ Özellikler

### 🎯 Eğitim İçeriği
- **Sınıf Bazlı Organizasyon**: Her sınıf için özel içerik
- **Ders Kategorileri**: Matematik, Fen, Türkçe, Sosyal Bilimler ve daha fazlası
- **İnteraktif Testler**: Zorluk seviyelerine göre sınıflandırılmış testler
- **Bilgi Kartları (Flashcards)**: Konuları pekiştirmek için swipe-tabanlı kartlar
- **Sonuç Ekranları**: Detaylı puan ve istatistik gösterimi

### 📱 Kullanıcı Deneyimi
- **Profil Yönetimi**: Öğrenci bilgilerini kaydetme ve takip
- **İlerleme Takibi**: Test sonuçları ve öğrenme geçmişi
- **Karanlık Mod**: Optimize edilmiş göz dostu arayüz
- **Offline Desteği**: İnternetsiz çalışabilme
- **Bildirimler (v1.6.0)**: 
  - 🔴 **Akıllı Red Dot**: Sadece okunmamış bildirimlerde yanar.
  - 🔔 **In-App Overlay**: Uygulama açıkken rahatsız etmeyen bildirimler.
  - 📅 **Haftalık Senaryo**: 14 farklı otomatik bildirim.
  - [Detaylı Rapor İçin Tıklayın](./NOTIFICATION_SYSTEM_REPORT.md)
- **Türkçe Localization**: Tam Türkçe tarih ve zaman desteği

### 🎮 Mini Oyunlar (4 Oyun)
- **Cümle Tamamlama**: Drag & drop ile boşluk doldurma (seviye seçimli)
- **1v1 Düello**: Akıllı bot ile yarış modu (Test veya Cümle Tamamlama)
- **Salla Bakalım**: Telefonu salla, sayıyı tahmin et (seviye seçimli)
- **Bul Bakalım**: 1'den 10'a kadar sıralı hafıza oyunu
- **Maskot Sistemi**: Öğrenme sürecinde eşlik eden sanal arkadaş

### 📳 Akıllı Shake Sistemi
- **Ana Sayfa Shake**: Telefonu salla, rastgele içerik önerisi al
- **sensors_plus ile Hassas Algılama**: Daha güvenilir shake detection
- **Çakışma Önleme**: Oyun ekranlarında otomatik devre dışı (pause/resume)
- **İçerik Türleri**: Test, Bilgi Kartı veya 4 oyundan rastgele biri

### 🤖 Akıllı 1v1 Düello Sistemi
- **100 Türkçe Bot İsmi**: 50 erkek, 50 kadın ismi (Ahmet, Ayşe, Zeynep vb.)
- **Akıllı Bot Algoritması**:
  - Kullanıcı öndeyse → Bot doğru cevap verir (kullanıcıyı zorlar)
  - Kullanıcı gerideyse → Bot yanlış cevap verir (kullanıcıya şans verir)
  - Berabere → Sırayla doğru/yanlış cevap verir
- **İnternet Kontrolü**: Eğlenceli deneyim için internet bağlantısı kontrolü
- **Matchmaking Animasyonu**: 3-5 saniye "Rakip Aranıyor" efekti
- **2 Oyun Modu**: Test soruları veya Cümle Tamamlama

### 📝 Türkiye Geneli Haftalık Sınav
- **500 Tam Puan**: Her sınav 500 puan üzerinden değerlendirilir
- **Haftalık Sınav**: Her hafta yeni sınav yayınlanır
- **Zaman Duyarlı**: Pazartesi 00:00 - Çarşamba 23:59 arası aktif
- **Tek Giriş Hakkı**: Kullanıcı sınava sadece 1 kez girebilir
- **Sonuç Beklemesi**: Pazar 12:00'da sonuçlar açıklanır
- **Türkiye Sıralaması**: Tüm katılımcılar arasında sıralama
- **4 Yanlış = 1 Doğru**: Net hesaplama formülü
- **Otomatik Temizlik**: Yeni sınav geldiğinde eski veriler silinir

### 🔄 Akıllı Sync Sistemi
- **Manifest Tabanlı**: Sadece yeni içerikleri indirir
- **Haftalık Güncellemeler**: Otomatik içerik güncellemeleri
- **tar.bz2 Formatı**: Optimize edilmiş sıkıştırma
- **İnkremental Sync**: Bandwidth tasarrufu
- **Veritabanı İlk Depolama**: Tüm oyun içerikleri lokal SQLite'ta

---

## 📱 Ekranlar

Uygulamada toplam **33 ekran/dialog** bulunmaktadır:

### 🔐 1. Giriş ve Onboarding (4 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 1 | Splash Screen | `lib/screens/splash_screen.dart` | Uygulama açılış ekranı, logo animasyonu |
| 2 | Login Screen | `lib/screens/login_screen.dart` | Google ile giriş |
| 3 | Profile Setup Screen | `lib/screens/profile_setup_screen.dart` | İl/İlçe/Okul/Sınıf seçimi |
| 4 | Mascot Selection Screen | `lib/features/mascot/presentation/screens/pet_selection_screen.dart` | Kedi/Köpek/Tavşan maskot seçimi |

### 🏠 2. Ana Uygulama - Tab Yapısı (5 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 5 | Main Screen | `lib/screens/main_screen.dart` | Tab bar host, bottom navigation |
| 6 | Home Tab | `lib/screens/tabs/home_tab.dart` | Ana sayfa, interaktif maskot, hızlı erişim kartları |
| 7 | Lessons Tab | `lib/screens/tabs/lessons_tab.dart` | Dersler, haftalık sınav kartı, bilgi kartları |
| 8 | Games Tab | `lib/screens/tabs/games_tab.dart` | Oyunlar listesi (4 oyun) |
| 9 | Profile Tab | `lib/screens/tabs/profile_tab.dart` | Kullanıcı profili, ayarlar |

### 📚 3. Ders ve İçerik Ekranları (6 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 10 | Lesson Selection Screen | `lib/screens/lesson_selection_screen.dart` | Ders seçimi (Matematik, Fen, Türkçe vb.) |
| 11 | Topic Selection Screen | `lib/screens/topic_selection_screen.dart` | Konu/Ünite seçimi |
| 12 | Test Screen | `lib/screens/test_screen.dart` | Çoktan seçmeli test ekranı |
| 13 | Flashcards Screen | `lib/screens/flashcards_screen.dart` | Bilgi kartları (swipe) |
| 14 | Flashcard Set Selection Screen | `lib/screens/flashcard_set_selection_screen.dart` | Bilgi kartı seti seçimi |
| 15 | Result Screen | `lib/screens/result_screen.dart` | Test sonuç ekranı |

### 📝 4. Haftalık Sınav (3 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 16 | Weekly Exam Card | `lib/features/exam/presentation/widgets/weekly_exam_card.dart` | Dersler tab'ındaki sınav kartı (widget) |
| 17 | Weekly Exam Screen | `lib/features/exam/presentation/screens/weekly_exam_screen.dart` | Haftalık sınav soruları |
| 18 | Weekly Exam Result Screen | `lib/features/exam/presentation/screens/weekly_exam_result_screen.dart` | Sınav sonuçları (500 puan üzerinden) |

### 🎮 5. Oyunlar

#### 5.1 Cümle Tamamlama (2 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 19 | Level Selection Screen | `lib/features/games/fill_blanks/presentation/screens/level_selection_screen.dart` | Seviye seçimi |
| 20 | Fill Blanks Screen | `lib/features/games/fill_blanks/presentation/screens/fill_blanks_screen.dart` | Cümle tamamlama oyunu |

#### 5.2 1v1 Düello (3 Ekran + 1 Dialog)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 21 | Duel Selection Screen | `lib/features/duel/presentation/screens/duel_selection_screen.dart` | Test/Cümle Tamamlama seçimi |
| 22 | Matchmaking Screen | `lib/features/duel/presentation/screens/matchmaking_screen.dart` | "Rakip Aranıyor" animasyonu |
| 23 | Duel Game Screen | `lib/features/duel/presentation/screens/duel_game_screen.dart` | Düello oyun ekranı |
| 24 | Duel Result Dialog | `lib/features/duel/presentation/widgets/duel_result_dialog.dart` | Kazanan/Kaybeden dialogu |

#### 5.3 Salla Bakalım (3 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 25 | Guess Level Selection Screen | `lib/features/games/guess/presentation/screens/guess_level_selection_screen.dart` | Seviye seçimi |
| 26 | Guess Game Screen | `lib/features/games/guess/presentation/screens/guess_game_screen.dart` | Sayı tahmin oyunu (telefon sallama) |
| 27 | Guess Result Screen | `lib/features/games/guess/presentation/screens/guess_result_screen.dart` | Oyun sonucu |

#### 5.4 Bul Bakalım (2 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 28 | Memory Game Screen | `lib/features/games/memory/presentation/screens/memory_game_screen.dart` | Hafıza kartı oyunu |
| 29 | Memory Result Screen | `lib/features/games/memory/presentation/screens/memory_result_screen.dart` | Oyun sonucu |

### 🏆 6. Başarılar ve İstatistikler (1 Ekran, 5 Sekme)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 30 | Achievements Screen | `lib/screens/achievements_screen.dart` | 5 sekmeli başarı ekranı |
| | - Tab 1: Testler | | Test sonuçları listesi |
| | - Tab 2: Cümle | | Cümle tamamlama sonuçları |
| | - Tab 3: Kartlar | | Bilgi kartı istatistikleri |
| | - Tab 4: Salla | | Salla Bakalım sonuçları |
| | - Tab 5: Bul | | Bul Bakalım sonuçları |

### ⚙️ 7. Ayarlar ve Yasal (3 Ekran)

| # | Ekran | Dosya | Açıklama |
|---|-------|-------|----------|
| 31 | Settings Screen | `lib/screens/settings_screen.dart` | Uygulama ayarları |
| 32 | Privacy Policy Screen | `lib/screens/privacy_policy_screen.dart` | Gizlilik politikası |
| 33 | Terms of Service Screen | `lib/screens/terms_of_service_screen.dart` | Kullanım şartları |

---

## 📊 Ekran Özet İstatistikleri

| Kategori | Ekran Sayısı |
|----------|--------------|
| Giriş ve Onboarding | 4 |
| Ana Uygulama (Tab Yapısı) | 5 |
| Ders ve İçerik | 6 |
| Haftalık Sınav | 3 |
| Oyunlar - Cümle Tamamlama | 2 |
| Oyunlar - 1v1 Düello | 4 |
| Oyunlar - Salla Bakalım | 3 |
| Oyunlar - Bul Bakalım | 2 |
| Başarılar | 1 (5 sekme) |
| Ayarlar ve Yasal | 3 |
| **TOPLAM** | **33 Ekran/Dialog** |

---

## 🗺️ Kullanıcı Akış Diyagramı

```
┌─────────────────────────────────────────────────────────────────┐
│                        UYGULAMA BAŞLANGIÇ                        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────┐
                    │   Splash Screen   │
                    └───────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            Giriş Yapılmış?           Giriş Yapılmamış
                    │                       │
                    ▼                       ▼
          ┌─────────────────┐    ┌───────────────────┐
          │   Main Screen   │    │   Login Screen    │
          └─────────────────┘    └───────────────────┘
                    │                       │
                    │                       ▼
                    │            ┌───────────────────────┐
                    │            │ Profile Setup Screen  │
                    │            └───────────────────────┘
                    │                       │
                    │                       ▼
                    │            ┌───────────────────────┐
                    │            │ Mascot Selection      │
                    │            └───────────────────────┘
                    │                       │
                    └───────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         MAIN SCREEN                              │
│  ┌──────────┬──────────┬──────────┬──────────┐                  │
│  │  🏠 Ana  │  📚 Ders │  🎮 Oyun │  👤 Profil│                  │
│  │  Sayfa   │   ler    │   lar    │          │                  │
│  └──────────┴──────────┴──────────┴──────────┘                  │
└─────────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Home Tab   │  │ Lessons Tab │  │  Games Tab  │  │ Profile Tab │
│             │  │             │  │             │  │             │
│ • Maskot    │  │ • Haftalık  │  │ • Cümle     │  │ • Başarılar │
│ • Günlük    │  │   Sınav     │  │   Tamamlama │  │ • Ayarlar   │
│   Bilgi     │  │ • Bilgi     │  │ • 1v1       │  │ • Çıkış     │
│ • Hızlı     │  │   Kartları  │  │   Düello    │  │             │
│   Erişim    │  │ • Testler   │  │ • Salla     │  │             │
│             │  │             │  │   Bakalım   │  │             │
│             │  │             │  │ • Bul       │  │             │
│             │  │             │  │   Bakalım   │  │             │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
```

---

## 🎮 Oyun Akışları

### Cümle Tamamlama
```
Games Tab → Level Selection → Fill Blanks Screen → (Başarılar'a kayıt)
```

### 1v1 Düello
```
Games Tab → Duel Selection → İnternet Kontrolü → Matchmaking (3-5s) → Duel Game → Result Dialog
```

### Salla Bakalım
```
Games Tab → Guess Level Selection → Guess Game → Guess Result → (Başarılar'a kayıt)
```

### Bul Bakalım
```
Games Tab → Memory Game → Memory Result → (Başarılar'a kayıt)
```

---

## 🛠️ Teknoloji Stack

### Framework & Dil
- **Flutter** `3.9.2+` - Cross-platform UI framework
- **Dart** `^3.9.2` - Programming language

### Backend & Cloud
- **Firebase Core** `^3.8.0` - Firebase temel servisleri
- **Firebase Auth** `^5.3.3` - Kullanıcı kimlik doğrulama
- **Firebase Storage** `^12.3.7` - Dosya depolama
- **Cloud Firestore** `^5.5.1` - NoSQL veritabanı

### State Management & Architecture
- **Riverpod** `^2.6.1` - State management
- **Freezed** `^2.5.7` - Immutable models ve code generation
- **JSON Serialization** `^4.9.0` - JSON parsing

### Local Storage
- **SQLite** (sqflite `^2.3.0`) - Yerel veritabanı
- **Shared Preferences** `^2.2.2` - Key-value storage
- **Flutter Secure Storage** `^9.2.2` - Güvenli veri saklama

### UI & Media
- **Google Fonts** `^6.2.1` - Özel fontlar (Orbitron, Roboto)
- **Lottie** `^3.1.0` - Animasyonlar
- **flutter_animate** `^4.5.2` - Smooth UI animasyonları
- **Cached Network Image** `^3.4.1` - Resim cache
- **Confetti** `^0.7.0` - Kutlama animasyonları

### Sensors & Games
- **sensors_plus** `^6.1.1` - Accelerometer (Ana sayfa shake detection)

### Utilities
- **Archive** `^3.3.7` - tar.bz2 sıkıştırma/açma desteği
- **Logger** `^2.5.0` - Logging
- **Timezone** `^0.9.2` - Zaman dilimi yönetimi
- **Intl** `^0.19.0` - Internationalization (Türkçe desteği)

### Development
- **Build Runner** `^2.4.13` - Code generation
- **Flutter Lints** `^5.0.0` - Lint kuralları
- **Mockito** `^5.4.6` - Testing mocks
- **Flutter Test** - Unit ve widget testleri

---

## 🏗️ Mimari

Proje **Clean Architecture** prensiplerine göre organize edilmiştir:

```
lib/
├── core/                    # Temel yapılar
│   ├── constants/          # Sabitler
│   ├── providers/          # Global provider'lar
│   ├── theme/              # Tema yapılandırması
│   └── utils/              # Yardımcı fonksiyonlar
│
├── features/               # Özellik modülleri
│   ├── auth/              # Kimlik doğrulama
│   ├── mascot/            # Maskot sistemi
│   │   ├── domain/        # Entities & Repository interfaces
│   │   ├── data/          # Repository implementations
│   │   └── presentation/  # UI & Controllers
│   ├── test/              # Test modülü
│   │   ├── domain/
│   │   ├── controller/
│   │   └── presentation/
│   ├── duel/              # 1v1 Düello sistemi
│   │   ├── domain/        # BotLogicController, BotProfile, DuelEntities
│   │   ├── data/          # DuelRepository, ConnectivityService
│   │   ├── logic/         # DuelController (Riverpod)
│   │   └── presentation/  # Screens & Widgets
│   ├── games/             # Mini oyunlar
│   │   ├── fill_blanks/  # Cümle tamamlama
│   │   ├── guess/        # Salla Bakalım
│   │   └── memory/       # Bul Bakalım
│   ├── exam/              # Haftalık sınav
│   └── sync/              # Senkronizasyon
│
├── models/                # Veri modelleri (Freezed)
│   ├── lesson.dart
│   ├── topic.dart
│   ├── test.dart
│   ├── flashcard_model.dart
│   └── ...
│
├── repositories/          # Veri erişim katmanı
│   ├── test_repository.dart
│   ├── flashcard_repository.dart
│   └── ...
│
├── services/              # Servisler
│   ├── firebase_storage_service.dart
│   ├── database_helper.dart
│   ├── data_service.dart
│   ├── notification_service.dart
│   ├── shake_service.dart
│   └── ...
│
├── screens/               # UI Ekranları
│   ├── main_screen.dart
│   ├── test_screen.dart
│   ├── flashcards_screen.dart
│   ├── result_screen.dart
│   └── tabs/
│       ├── home_tab.dart
│       ├── lessons_tab.dart
│       ├── games_tab.dart
│       └── profile_tab.dart
│
├── widgets/               # Yeniden kullanılabilir widget'lar
│   ├── glass_container.dart
│   ├── custom_button.dart
│   └── ...
│
└── main.dart              # Uygulama giriş noktası
```

### Veri Akışı

```
Firebase Storage (tar.bz2)
         ↓
  FirebaseStorageService
         ↓
  Local SQLite Database
         ↓
    Repositories
         ↓
  Riverpod Providers
         ↓
        UI
```

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- Android Studio / VS Code
- Firebase hesabı ve yapılandırması

### Adımlar

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/Emire221/para.git
   cd para
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Code generation çalıştırın**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase yapılandırması**
   - `lib/firebase_options.dart` dosyasını kendi Firebase projenize göre güncelleyin
   - Android ve iOS için `google-services.json` ve `GoogleService-Info.plist` ekleyin

5. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

### Testleri Çalıştırma

```bash
# Tüm testleri çalıştır
flutter test

# Belirli bir test dosyasını çalıştır
flutter test test/services/firebase_storage_service_test.dart

# Test coverage raporu
flutter test --coverage
```

### Analiz

```bash
# Kod analizi
flutter analyze

# Lint kontrolleri
flutter analyze --no-fatal-warnings
```

**Güncel Durum:** ✅ No issues found!

---

## 📁 Proje Yapısı

### Veritabanı Şeması (SQLite)

```sql
-- Dersler
CREATE TABLE Dersler (
  dersID TEXT PRIMARY KEY,
  dersAdi TEXT,
  ikon TEXT,
  renk TEXT
);

-- Konular
CREATE TABLE Konular (
  konuID TEXT PRIMARY KEY,
  dersID TEXT,
  konuAdi TEXT,
  sira INTEGER,
  FOREIGN KEY(dersID) REFERENCES Dersler(dersID)
);

-- Testler
CREATE TABLE Testler (
  testID TEXT PRIMARY KEY,
  konuID TEXT,
  testAdi TEXT,
  zorluk INTEGER,
  cozumVideoURL TEXT,
  sorular TEXT, -- JSON
  FOREIGN KEY(konuID) REFERENCES Konular(konuID)
);

-- Bilgi Kartları
CREATE TABLE BilgiKartlari (
  kartSetID TEXT PRIMARY KEY,
  konuID TEXT,
  kartAdi TEXT,
  kartlar TEXT, -- JSON
  FOREIGN KEY(konuID) REFERENCES Konular(konuID)
);

-- Fill Blanks Levels (Cümle Tamamlama)
CREATE TABLE FillBlanksLevels (
  levelID TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  difficulty INTEGER,
  category TEXT,
  questions TEXT -- JSON
);

-- Guess Levels (Salla Bakalım)
CREATE TABLE GuessLevels (
  guessID TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  difficulty INTEGER,
  category TEXT,
  questions TEXT -- JSON
);

-- Game Results (Oyun Sonuçları)
CREATE TABLE GameResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gameType TEXT NOT NULL,
  score INTEGER,
  correctCount INTEGER,
  wrongCount INTEGER,
  totalQuestions INTEGER,
  completedAt TEXT,
  details TEXT
);

-- Memory Game Results (Bul Bakalım)
CREATE TABLE MemoryGameResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  moves INTEGER,
  timeTaken INTEGER,
  mistakes INTEGER,
  completedAt TEXT
);

-- User Pets (Maskot)
CREATE TABLE UserPets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  petType TEXT NOT NULL,
  petName TEXT NOT NULL,
  currentXp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  mood INTEGER DEFAULT 100,
  createdAt TEXT DEFAULT (datetime('now'))
);

-- Haftalık Sınavlar
CREATE TABLE WeeklyExams (
  weeklyExamId TEXT PRIMARY KEY,
  title TEXT,
  weekStart TEXT,
  duration INTEGER,
  description TEXT,
  questions TEXT -- JSON
);

-- Haftalık Sınav Sonuçları
CREATE TABLE WeeklyExamResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  examId TEXT NOT NULL,
  odaId TEXT NOT NULL,
  odaIsmi TEXT,
  odaBaslangic TEXT,
  odaBitis TEXT,
  sonucTarihi TEXT,
  odaDurumu TEXT,
  odaKatilimciId TEXT NOT NULL,
  cevaplar TEXT, -- JSON
  dogru INTEGER,
  yanlis INTEGER,
  bos INTEGER,
  puan INTEGER, -- 500 üzerinden
  siralama INTEGER,
  toplamKatilimci INTEGER,
  completedAt TEXT
);
```

---

## 🔄 Sync Sistemi

### Manifest Tabanlı Senkronizasyon

Uygulama, Firebase Storage'dan içerikleri akıllı bir şekilde indirir:

#### 1. Manifest Yapısı (`manifest.json`)

```json
{
  "version": "v2.0",
  "updatedAt": "2024-12-05T10:00:00Z",
  "files": [
    {
      "path": "3_Sinif/hafta_1.tar.bz2",
      "type": "tar.bz2",
      "version": "v1",
      "hash": "abc123...",
      "addedAt": "2024-12-05T10:00:00Z"
    }
  ]
}
```

#### 2. Sync Akışı

```
1. Manifest Download
   ↓
2. Versiyon Karşılaştırma
   ↓
3. Yeni Dosyaları Tespit Et
   ↓
4. tar.bz2 Arşivleri İndir
   ↓
5. BZip2 → Tar Decode
   ↓
6. Dosyaları Çıkart
   ↓
7. SQLite'a Kaydet (Oyun verileri de dahil)
   ↓
8. Local Manifest Güncelle
```

---

## 🧪 Testler

### Test İstatistikleri

- **Toplam Test**: 38
- **Başarılı**: 37
- **Başarısız**: 1 (firebase_storage_service_test)
- **Başarı Oranı**: %97.3
- **Coverage**: Unit, Widget, Integration

---

## 📊 Kod Kalitesi

### Analiz Sonuçları

```
✅ No issues found!
📊 Analyzed in 7.9s
🧪 37/38 tests passing
📈 97.3% success rate
```

---

## 📝 Son Güncellemeler

### [v1.6.0] - 2025-12-31

#### Added ✨
- **Akıllı Bildirim Sistemi**:
  - **Red Dot**: Sadece okunmamış bildirim varsa yanar.
  - **UI Overhaul**: Bildirim popup tasarımı yenilendi, header ortalandı, yükseklik optimize edildi.
  - **In-App Overlay**: Uygulama açıkken gelen bildirimler için özel Snackbar.
  - **14 Senaryo**: Haftalık otomatik bildirim planı.

#### Fixed 🐛
- **Notifications Screen**: Sola dayalı başlık ve tasarım sorunları giderildi.
- **Red Dot Logic**: Sürekli yanma sorunu çözüldü.

---

### [v1.5.0] - 2025-12-06

#### Added ✨
- **UI/UX Redesign**: Modern Neon tema sistemi
  - **Glassmorphism Design**: Buzlu cam efektli container'lar
  - **Neon Color Palette**: Vibrant gradient renkler
  - **flutter_animate Paketi**: Smooth animasyonlar
  - **Google Fonts (Orbitron)**: Futuristik tipografi
  - **2 Yeni Lottie Animasyonu**: `card_thoropy.json`, `match_macking.json`

- **Tema Grupları**:
  - **Neon Arena**: Matchmaking, Duel Selection, Duel Game
  - **Neon Brain**: Memory Game, Memory Result
  - **Shake Wave**: Guess Level Selection, Guess Game, Guess Result
  - **Neon Review**: Answer Key Screen
  - **Neon Notification**: Notifications Screen

#### Changed 🔄
- **Matchmaking Screen**: Neon Arena tema + Lottie animasyonu
- **Duel Selection Screen**: Glass bottom sheet design
- **Duel Game Screen**: Battle Arena tema
- **Memory Game Screen**: Neon Brain tema ile akıcı kart animasyonları
- **Memory Result Screen**: Victory Celebration tasarımı
- **Guess Level Selection**: Shake Wave gradient tema
- **Guess Game Screen**: Temperature-based arka plan renkleri
- **Guess Result Screen**: Shake Wave Victory kutlaması
- **Notifications Screen**: Neon Notification popup tasarımı
- **Answer Key Screen**: Neon Review tema ile glassmorphism kartlar
- **Fill Blanks Screen**: Neon gradient arka planlar
- **Level Selection Screen**: Modern glass morphism
- **Weekly Exam Screens**: Modern tasarım güncellemeleri

#### İstatistikler (v1.5.0)
- 📝 18 dosya değişti
- ➕ 10,453 satır eklendi
- ➖ 3,115 satır silindi
- 🎨 5 yeni tema grubu
- 🎬 2 yeni Lottie animasyonu
- ✅ 0 lint hatası

---

### [v1.4.0] - 2025-12-05

#### Added ✨
- **1v1 Düello Sistemi**: Akıllı bot ile yarış modu
  - 100 Türkçe bot ismi (50 erkek, 50 kadın)
  - Akıllı bot algoritması (kullanıcı durumuna göre davranış)
  - Test ve Cümle Tamamlama modları
  - İnternet kontrolü (ConnectivityService)
  - Matchmaking animasyonu (3-5 saniye)
  - Skor tablosu ve sonuç dialogu

#### Removed 🗑️
- **Arena Düello Sistemi**: Eski arena modülü tamamen kaldırıldı
  - `lib/features/games/arena/` klasörü silindi
  - ArenaSets veritabanı tablosu kaldırıldı
  - İlgili tüm referanslar temizlendi

#### Changed 🔄
- **Games Tab**: Arena yerine 1v1 Düello kartı
- **ShakeService**: Düello içerik tipi eklendi
- **DatabaseHelper**: Arena metodları kaldırıldı

#### Fixed 🐛
- **Lint Sorunları**: duel_controller.dart'taki curly braces eksiklikleri giderildi
- **Import Çakışmaları**: DuelFillBlankQuestion widget/entity isim çakışması çözüldü

### İstatistikler (v1.4.0)
- 📝 20+ dosya değişti
- ➕ 2000+ satır eklendi
- ➖ 1500+ satır silindi (Arena kaldırıldı)
- 🎮 1v1 Düello sistemi eklendi
- ✅ 0 lint hatası

---

### [v1.3.0] - 2025-12-04

#### Added ✨
- **Salla Bakalım Oyunu**: Telefonu sallayarak sayı tahmin etme (10 seviyeli)
- **Bul Bakalım Oyunu**: 1-10 arası sıralı hafıza oyunu
- **sensors_plus Entegrasyonu**: Ana sayfa shake algılama daha hassas ve güvenilir
- **ShakeService pause/resume**: Oyun ekranlarında çakışma önleme mekanizması
- **500 Puan Sistemi**: Haftalık sınav puanlaması 500 tam puan üzerinden
- **Confetti Kutlamaları**: Oyun sonunda konfeti animasyonları

---

### [v1.2.0] - 2025-12-04

#### Added ✨
- **Haftalık Sınav Sistemi**: Türkiye geneli deneme sınavı özelliği
- **WeeklyExamCard**: Dersler ekranında her zaman görünen sınav kartı
- **clearOldWeeklyExamData()**: Yeni sınav geldiğinde eski verileri temizleme

---

### [v1.1.0] - 2024-12-03

#### Added ✨
- **Maskot Sistemi**: Öğrencilere eşlik eden sanal arkadaş
- **ResultScreen Entegrasyonu**: Flashcards için detaylı sonuç ekranı
- **Türkçe Localization**: İntl paketi ile tam Türkçe tarih desteği

---

## 🤝 Katkıda Bulunma

Bu proje özel bir projedir. Katkı kabul edilmemektedir.

---

## 📄 Lisans

Bu proje özel mülkiyettir. Tüm hakları saklıdır.

---

## 📞 İletişim

- **Repository**: [github.com/Emire221/BilgiAvcisi](https://github.com/Emire221/BilgiAvcisi)
- **Issues**: GitHub Issues'ı kullanın

---

## 📚 Ek Kaynaklar

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Guide](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)

---

**Geliştirici**: Emire221  
**Son Güncelleme**: 31 Aralık 2025  
**Versiyon**: 1.6.0

---

<p align="center">Made with ❤️ for Turkish Students</p>
