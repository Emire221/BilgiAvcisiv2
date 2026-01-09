# Bilgi Avcısı - Optimizasyon ve Sağlık Raporu

**Tarih:** 24 Mayıs 2024
**Analizi Yapan:** Senior Flutter Architect
**Genel Sağlık Skoru:** 7/10

---

## 1. Özet
Proje, `Flutter` ve `Firebase` mimarisi üzerine kurulu, modern UI kütüphaneleri (`flutter_animate`, `glass_container` vb.) ile zenginleştirilmiş bir eğitim uygulamasıdır. Genel mimari yapısı modüler (features/core/widgets) olsa da, özellikle veri işleme ve liste render etme süreçlerinde ciddi performans darboğazları (bottlenecks) mevcuttur. UX açısından görsel zenginlik ön planda tutulmuş ancak büyük ekran uyumluluğu ve scroll yönetimi bazı ekranlarda atlanmıştır.

---

## 2. Kritik Sorunlar (High Priority)

Uygulamanın performansını doğrudan etkileyen ve potansiyel çökme/donma (ANR) riski taşıyan sorunlar aşağıdadır.

### 🔴 2.1. Main Thread Blocking (Ana İş Parçacığı Bloklanması)
**Dosya:** `lib/screens/profile_setup_screen.dart`
**Sorun:** Büyük JSON dosyaları (`siniflar.json`, `cities.json`) ana thread üzerinde senkron olarak decode ediliyor. Ayrıca `_onCityChanged` metodunda binlerce okul verisi ana thread'de filtreleniyor. Bu işlem, düşük donanımlı cihazlarda UI'ın donmasına (Frame Skip) neden olur.

**Hatalı Kod (Satır ~84):**
```dart
final response = await rootBundle.loadString('assets/json/siniflar.json');
final data = json.decode(response); // <--- CPU Intensive işlem Main Thread'de!
```

**Çözüm Önerisi:**
JSON parse işlemleri ve ağır filtreleme mantığı `compute` fonksiyonu (Isolate) kullanılarak arka plana taşınmalıdır.

```dart
// Çözüm
final data = await compute(jsonDecode, response);
```

### 🔴 2.2. Rendering Issues (Gereksiz Render Maliyeti)
**Dosya:** `lib/features/exam/presentation/screens/weekly_exam_result_screen.dart`
**Sorun:** Sınav sonuç ekranında, çok sayıda soru (örn: 100 soru) `SingleChildScrollView` içerisindeki bir `Column` (veya map döngüsü) ile ekrana basılıyor. Bu yöntem, ekranda görünmeyen soruların bile render edilmesine neden olarak bellek tüketimini artırır ve açılış hızını düşürür.

**Hatalı Yapı:**
```dart
// _buildDetailedAnswers metodu içinde
...widget.exam.questions.asMap().entries.map((entry) {
  // Tüm sorular anında render ediliyor
  return _buildAnswerRow(...);
}),
```

**Çözüm Önerisi:**
`ListView.builder` kullanılarak sadece ekranda görünen elemanların render edilmesi (Lazy Loading) sağlanmalıdır.

### 🔴 2.3. Global Error Swallowing (Hataların Yutulması)
**Dosya:** `lib/main.dart`
**Sorun:** Geliştirme ve Production ortamı ayrımı yapılmaksızın tüm global hatalar yakalanıp boş bir widget (`SizedBox.shrink`) döndürülüyor. Bu durum, production ortamında kritik hataların loglanmasını engeller ve geliştirme sırasında hatanın kaynağını bulmayı imkansız hale getirir.

**Hatalı Kod:**
```dart
ErrorWidget.builder = (FlutterErrorDetails details) {
  return const SizedBox.shrink(); // <--- Hata görseli yok ediliyor
};
```

**Çözüm Önerisi:**
Sadece `kReleaseMode` (Production) modunda kullanıcı dostu bir hata ekranı gösterilmeli, `kDebugMode` modunda ise standart kırmızı hata ekranı korunmalıdır.

---

## 3. Performans ve Darboğaz Analizi

### ⚠️ ShrinkWrap Kullanımı
`ListView` ve `GridView` içerisinde `shrinkWrap: true` kullanımı performansı olumsuz etkiler çünkü listenin boyutunu hesaplamak için tüm elemanların önceden render edilmesini zorunlu kılar.
- **Tespit Edilen Yerler:**
  - `lib/screens/profile_setup_screen.dart` (İç içe scroll yapıları)
  - `lib/features/duel/presentation/widgets/duel_fill_blank_question.dart`
  - `lib/screens/tabs/profile_tab.dart`

**Çözüm:** Mümkünse `CustomScrollView` ve `Slivers` yapısına geçilmeli veya liste elemanlarına sabit yükseklik (itemExtent) verilmelidir.

### ⚠️ State Management Karışıklığı
Projede hem `Riverpod` (`ConsumerStatefulWidget`) hem de `Provider` (pubspec.yaml bağımlılığı ve bazı context kullanımları) görülmektedir. İki farklı state yönetim kütüphanesinin aynı anda kullanılması mimari karmaşaya ve gereksiz rebuild'lere yol açabilir. Projenin tamamen `Riverpod`'a geçirilmesi önerilir.

---

## 4. UX/UI İyileştirme Önerileri

### 📱 Scroll vs. Fixed Layout
**Ekran:** `LoginScreen` ve `RegisterScreen`
**Durum:** `SingleChildScrollView` kullanılmış. Klavye açıldığında bu gereklidir ancak büyük ekranlarda veya klavye kapalıyken içerik dikeyde ortalanmalı ve gereksiz scroll oluşmamalıdır.
**Öneri:** `LayoutBuilder` kullanılarak ekran boyutuna göre `minHeight` verilmeli ve içerik `Column` içinde `MainAxisAlignment.center` ile ortalanmalıdır. `SliverFillRemaining` widget'ı bu senaryo için idealdir.

### 👆 Responsive Design
**Ekran:** `ProfileSetupScreen`
**Durum:** Kod içerisinde `isTablet`, `isSmallPhone` gibi bool değişkenlerle manuel responsive mantığı kurulmuş.
**Öneri:** Flutter'ın `LayoutBuilder` veya `flutter_screenutil` gibi paketleri ile daha sistematik bir responsive yapı kurulabilir. `MediaQuery` ile yapılan `screenHeight < 700` gibi kontroller maintenance (bakım) maliyetini artırır.

---

## 5. Code Hygiene (Kod Temizliği)

- **DRY (Don't Repeat Yourself):** `LoginScreen` ve `RegisterScreen` içerisinde benzer input dekorasyonları ve buton stilleri tekrar ediyor. Bunlar `SharedInputDecoration` veya `CustomButton` gibi ortak widget'lara taşınmalıdır.
- **Async Logic:** `ProfileSetupScreen` içerisinde `_loadInitialData` metodu `Future.wait` kullanıyor, bu güzel bir yaklaşım. Ancak `json.decode` işlemi senkron olduğu için bu paralelliğin avantajını UI thread bloklanarak kaybediyor.

---

## 6. Emülatör ve Build Notları
- **Skipped Frames:** `ProfileSetupScreen` geçişinde ve şehir seçimi sırasında konsolda "Skipped xx frames" uyarısı görülmesi muhtemeldir. Yukarıda bahsedilen JSON parse optimizasyonu bu sorunu çözecektir.

---

**Sonuç:** Proje görsel olarak güçlü ancak veri yoğun işlemler altında performans sorunları yaşatabilecek kritik hatalara sahip. Öncelikli olarak JSON parse işlemlerinin izole edilmesi ve liste yapılarının optimize edilmesi gerekmektedir.
