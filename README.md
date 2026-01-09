<p align="center">
  <img src="assets/appicon/main_logo.png" alt="Bilgi Avcısı Logo" width="120" height="120">
</p>

<h1 align="center">🎯 Bilgi Avcısı</h1>

<p align="center">
  <strong>Türk Öğrenciler İçin Oyunlaştırılmış Eğitim Platformu</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform">
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/State%20Management-Riverpod-purple" alt="Riverpod">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-blue" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/Code%20Gen-Freezed-orange" alt="Freezed">
</p>

---

## 📋 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Özellikler](#-özellikler)
- [Teknoloji Stack](#-teknoloji-stack)
- [Mimari](#-mimari)
- [Kurulum](#-kurulum)
- [Proje Yapısı](#-proje-yapısı)
- [Ekranlar](#-ekranlar)
- [Servisler](#-servisler)
- [State Management](#-state-management)
- [Katkıda Bulunma](#-katkıda-bulunma)

---

## 🎯 Proje Hakkında

**Bilgi Avcısı**, 3-8. sınıf öğrencilerine yönelik, oyunlaştırılmış öğrenme deneyimi sunan kapsamlı bir eğitim platformudur. Uygulama, geleneksel test çözme deneyimini eğlenceli hale getirerek öğrencilerin motivasyonunu artırmayı hedefler.

### 🎮 Temel Konsept

- **Maskot Sistemi**: Her öğrenci kendi sanal evcil hayvanını seçer ve besler
- **XP & Seviye**: Çözülen testlerle XP kazanılır, seviye atlanır
- **Haftalık Sınavlar**: Her hafta düzenlenen canlı sınavlara katılım
- **1v1 Düello**: Arkadaşlarla veya botlarla bilgi yarışması
- **Başarım Rozetleri**: Çeşitli görevleri tamamlayarak rozet kazanma
- **Sıralama Tablosu**: İl, ilçe ve Türkiye geneli sıralama

---

## ✨ Özellikler

### 📚 Eğitim Modülleri

| Özellik | Açıklama |
|---------|----------|
| **Konu Testleri** | Ders ve konuya göre filtrelenebilir test havuzu |
| **Haftalık Sınav** | Pazartesi-Cuma arası çözülebilen haftalık değerlendirme |
| **Flashcard'lar** | Kelime ve kavram kartları ile tekrar |
| **Cevap Anahtarı** | Çözülen testlerin detaylı analizi |
| **İlerleme Analizi** | Ders bazlı performans grafikleri |

### 🎮 Oyunlaştırma

| Özellik | Açıklama |
|---------|----------|
| **Maskot Seçimi** | 5 farklı karakter (Kedi, Köpek, Tavşan, Maymun, Kaplan) |
| **Konuşan Maskot** | Ses kaydı yapıp maskotun seslendirmesiyle dinleme |
| **XP Sistemi** | Her doğru cevap için XP kazanımı |
| **Seviye Atlama** | Birikimli XP ile seviye yükseltme |
| **Rozetler** | 40+ farklı başarım rozeti |
| **Günlük Bilgi** | Her gün yeni bir bilgi kartı |

### ⚔️ Rekabet Modları

| Özellik | Açıklama |
|---------|----------|
| **1v1 Düello** | Gerçek zamanlı bilgi yarışması |
| **Bot Eşleşme** | Yapay zeka rakipler ile pratik |
| **Sıralama** | İl, ilçe, okul ve Türkiye sıralaması |
| **Haftalık Liderlik** | Her hafta sıfırlanan yarış |

### 🔔 Bildirimler

| Özellik | Açıklama |
|---------|----------|
| **Yerel Bildirimler** | Hatırlatmalar ve motivasyon mesajları |
| **Zamanlanmış Alarmlar** | Günlük çalışma hatırlatıcısı |
| **Sınav Bildirimleri** | Haftalık sınav başlangıç/bitiş uyarıları |

---

## 🛠 Teknoloji Stack

### Frontend
```
Flutter 3.9.2          → Cross-platform UI framework
Dart 3.9.2             → Programlama dili
Material Design 3      → UI tasarım sistemi
Google Fonts           → Tipografi (Nunito, Poppins)
```

### State Management & Architecture
```
Riverpod 2.6.1         → Reactive state management
Freezed 2.5.7          → Immutable data classes
JSON Serializable      → JSON encode/decode
Clean Architecture     → Katmanlı mimari
```

### Backend & Database
```
Firebase Core          → Firebase altyapısı
Firebase Auth          → Kullanıcı kimlik doğrulama
Cloud Firestore        → NoSQL veritabanı
Firebase Storage       → Dosya depolama (içerik arşivleri)
SQLite (sqflite)       → Yerel veritabanı
Shared Preferences     → Key-value depolama
```

### Animasyon & UI
```
Lottie 3.3.0           → JSON animasyonlar
Flutter Animate        → Declarative animasyonlar
Confetti               → Kutlama efektleri
FL Chart               → Grafik ve istatistikler
Percent Indicator      → İlerleme göstergeleri
```

### Ses & Medya
```
Record 6.0.0           → Ses kaydı
Just Audio             → Ses oynatma
Permission Handler     → İzin yönetimi
Share Plus             → İçerik paylaşımı
Gal                    → Galeri kaydetme
```

### Bildirimler
```
Flutter Local Notifications  → Yerel bildirimler
Android Alarm Manager Plus   → Zamanlanmış alarmlar
Timezone                     → Zaman dilimi desteği
```

---

## 🏗 Mimari

Proje, **Clean Architecture** prensiplerine uygun olarak 3 katmanlı bir yapıda tasarlanmıştır:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                         │
│  (Screens, Widgets, Controllers, State Management)      │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN                             │
│  (Models, Entities, Use Cases, Repository Interfaces)   │
├─────────────────────────────────────────────────────────┤
│                       DATA                              │
│  (Repositories, Data Sources, Services, API Clients)    │
└─────────────────────────────────────────────────────────┘
```

### Feature-Based Organization

Her feature kendi içinde bağımsız bir modül olarak organize edilmiştir:

```
features/
├── duel/           → 1v1 düello sistemi
├── exam/           → Haftalık sınav modülü
├── mascot/         → Maskot ve XP sistemi
├── sync/           → İçerik senkronizasyonu
├── test/           → Test çözme modülü
└── user/           → Kullanıcı yönetimi
```

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK 3.9.2 veya üzeri
- Dart SDK 3.9.2 veya üzeri
- Android Studio / VS Code
- Firebase projesi (yapılandırılmış)

### Adımlar

1. **Repoyu klonlayın**
```bash
git clone https://github.com/your-repo/bilgi-avcisi.git
cd bilgi-avcisi
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Kod üretimini çalıştırın**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Firebase yapılandırması**
```bash
flutterfire configure
```

5. **Uygulamayı çalıştırın**
```bash
flutter run
```

### Platform Özel Kurulum

#### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

#### iOS
```bash
# Simulator
flutter run -d ios

# Release IPA
flutter build ipa
```

#### Web
```bash
flutter build web
```

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── firebase_options.dart        # Firebase yapılandırması
│
├── core/                        # Çekirdek modüller
│   ├── constants/               # Sabitler
│   │   ├── app_constants.dart   # Uygulama sabitleri
│   │   └── lesson_weights.dart  # Ders ağırlıkları
│   ├── gamification/            # Oyunlaştırma mantığı
│   │   ├── mascot_logic.dart    # Maskot davranışları
│   │   └── mascot_phrases.dart  # Maskot cümleleri
│   ├── providers/               # Core providers
│   │   ├── auth_provider.dart   # Auth state
│   │   ├── sync_provider.dart   # Sync state
│   │   └── user_provider.dart   # User state
│   ├── utils/                   # Yardımcı araçlar
│   │   ├── logger.dart          # Loglama
│   │   └── responsive.dart      # Responsive helper
│   └── navigator_key.dart       # Global navigator key
│
├── features/                    # Özellik modülleri
│   ├── duel/                    # Düello sistemi
│   │   ├── data/                # Veri katmanı
│   │   ├── domain/              # Domain katmanı
│   │   ├── logic/               # İş mantığı
│   │   └── presentation/        # UI katmanı
│   ├── exam/                    # Haftalık sınav
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── mascot/                  # Maskot sistemi
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── sync/                    # İçerik senkronizasyonu
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── test/                    # Test çözme
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── user/                    # Kullanıcı yönetimi
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── models/                      # Veri modelleri
│   ├── flashcard_model.dart     # Flashcard
│   ├── question_model.dart      # Soru
│   ├── test_model.dart          # Test
│   ├── topic_model.dart         # Konu
│   ├── notification_data.dart   # Bildirim
│   └── models.dart              # Model exports
│
├── providers/                   # Global providers
│   ├── theme_provider.dart      # Tema state
│   └── repository_providers.dart# Repository DI
│
├── repositories/                # Data repositories
│   └── ...
│
├── screens/                     # Uygulama ekranları
│   ├── tabs/                    # Ana tab ekranları
│   │   ├── home_tab.dart        # Ana sayfa
│   │   ├── lessons_tab.dart     # Dersler
│   │   ├── games_tab.dart       # Oyunlar
│   │   └── profile_tab.dart     # Profil
│   ├── splash_screen.dart       # Açılış
│   ├── login_screen.dart        # Giriş
│   ├── register_screen.dart     # Kayıt
│   ├── profile_setup_screen.dart# Profil kurulumu
│   ├── main_screen.dart         # Ana ekran (tab host)
│   ├── test_screen.dart         # Test çözme
│   ├── result_screen.dart       # Sonuç
│   ├── achievements_screen.dart # Başarımlar
│   ├── flashcards_screen.dart   # Flashcard'lar
│   └── ...
│
├── services/                    # Servis katmanı
│   ├── database_helper.dart     # SQLite helper
│   ├── data_service.dart        # Veri servisi
│   ├── firebase_storage_service.dart # Firebase Storage
│   ├── notification_service.dart# Bildirim servisi
│   ├── local_preferences_service.dart # Preferences
│   ├── time_tracking_service.dart # Süre takibi
│   ├── progress_service.dart    # İlerleme servisi
│   └── ...
│
├── util/                        # Yardımcı araçlar
│   └── app_colors.dart          # Renk paleti
│
└── widgets/                     # Ortak widget'lar
    ├── auth/                    # Auth widget'ları
    │   ├── auth_widgets.dart    # Export dosyası
    │   ├── auth_text_field.dart # Text field
    │   └── auth_button.dart     # Button
    ├── glass_container.dart     # Glassmorphism
    ├── in_app_notification.dart # In-app bildirim
    └── motivation_progress_bar.dart # Progress bar
```

---

## 📱 Ekranlar

### 🔐 Auth Akışı
| Ekran | Dosya | Açıklama |
|-------|-------|----------|
| Splash | `splash_screen.dart` | Açılış animasyonu |
| Login | `login_screen.dart` | E-posta/şifre girişi |
| Register | `register_screen.dart` | Yeni hesap oluşturma |
| Profile Setup | `profile_setup_screen.dart` | İl/ilçe/okul/sınıf seçimi |
| Pet Selection | `pet_selection_screen.dart` | Maskot seçimi |

### 🏠 Ana Sekmeler
| Sekme | Dosya | Açıklama |
|-------|-------|----------|
| Ana Sayfa | `home_tab.dart` | Günlük özet, hızlı erişim |
| Dersler | `lessons_tab.dart` | Ders ve konu listesi |
| Oyunlar | `games_tab.dart` | Düello, flashcard, mini oyunlar |
| Profil | `profile_tab.dart` | Kullanıcı bilgileri, ayarlar |

### 📝 Test Ekranları
| Ekran | Dosya | Açıklama |
|-------|-------|----------|
| Ders Seçimi | `lesson_selection_screen.dart` | Ders filtresi |
| Konu Seçimi | `topic_selection_screen.dart` | Konu filtresi |
| Test Listesi | `test_list_screen.dart` | Test kartları |
| Test Çözme | `test_screen.dart` | Soru-cevap arayüzü |
| Sonuç | `result_screen.dart` | Puan ve analiz |
| Cevap Anahtarı | `answer_key_screen.dart` | Detaylı çözümler |

### 🎮 Oyun Ekranları
| Ekran | Dosya | Açıklama |
|-------|-------|----------|
| Matchmaking | `matchmaking_screen.dart` | Rakip eşleştirme |
| Duel Game | `duel_game_screen.dart` | Düello oyun ekranı |
| Duel Result | `duel_result_screen.dart` | Düello sonucu |
| Flashcards | `flashcards_screen.dart` | Kart çevirme |

### 📊 Analiz Ekranları
| Ekran | Dosya | Açıklama |
|-------|-------|----------|
| Progress | `progress_analytics_screen.dart` | İlerleme grafikleri |
| Time | `time_analytics_screen.dart` | Süre analitiği |
| Achievements | `achievements_screen.dart` | Rozetler ve başarımlar |
| Weekly Result | `weekly_exam_result_screen.dart` | Haftalık sınav sonucu |

---

## ⚙️ Servisler

### Database Helper
```dart
// SQLite veritabanı yönetimi
final db = await DatabaseHelper().database;
final topics = await db.query('Konular');
```

### Firebase Storage Service
```dart
// İçerik arşivi indirme
await FirebaseStorageService().downloadAndExtractContent(classLevel);
```

### Notification Service
```dart
// Yerel bildirim gönderme
await NotificationService().showNotification(
  title: 'Bilgi Avcısı',
  body: 'Günlük çalışma zamanı!',
);
```

### Time Tracking Service
```dart
// Ekran süresi takibi
await TimeTrackingService().start();
final stats = await TimeTrackingService().getWeeklyStats();
```

---

## 🔄 State Management

### Riverpod Providers

```dart
// Tema provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(...);

// Auth state
final authStateProvider = StreamProvider<User?>(...);

// User data
final userProvider = FutureProvider<UserModel?>(...);
```

### Kullanım

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    
    return ...;
  }
}
```

---

## 🎨 Tema Sistemi

### Renk Paleti

```dart
// Ana renkler
static const primaryPurple = Color(0xFF6C5CE7);
static const energeticCoral = Color(0xFFFF7675);
static const turquoise = Color(0xFF00CEC9);
static const softYellow = Color(0xFFFDCB6E);

// Dark mode
static const darkBg = Color(0xFF1A1A2E);
static const darkCard = Color(0xFF16213E);
```

### Light/Dark Mode

```dart
// Tema değiştirme
ref.read(themeProvider.notifier).toggleTheme(isDark);
```

---

## 🔧 Development

### Kod Üretimi

```bash
# Freezed & JSON Serializable
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch
```

### Linting

```bash
# Analiz
flutter analyze

# Otomatik düzeltme
dart fix --apply
```

### Test

```bash
# Tüm testler
flutter test

# Belirli test
flutter test test/services/firebase_storage_service_test.dart

# Coverage
flutter test --coverage
```

---

## 📦 Build & Deploy

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release --split-per-abi

# App Bundle
flutter build appbundle --release
```

### iOS

```bash
# IPA
flutter build ipa --release
```

### Web

```bash
# Production build
flutter build web --release --web-renderer canvaskit
```

---

## 📄 Lisans

Bu proje özel mülkiyettir. Tüm hakları saklıdır.

---

## 👨‍💻 Geliştirici

**Bilgi Avcısı** ekibi tarafından ❤️ ile geliştirilmiştir.

---

<p align="center">
  <strong>🎯 Bilgi Avcısı - Öğrenmeyi Eğlenceli Hale Getiriyoruz!</strong>
</p>
