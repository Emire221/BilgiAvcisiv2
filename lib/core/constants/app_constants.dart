/// Uygulama Sabitleri - Merkezi Tanımlamalar
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Test Configuration
  static const int defaultTestDuration = 60; // seconds
  static const int questionsPerTest = 10;
  static const int pointsPerCorrectAnswer = 10;
  static const int pointsPerWrongAnswer = 0;

  // Timer Configuration
  static const Duration timerInterval = Duration(seconds: 1);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // API Configuration (for future use)
  static const String apiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // UI Configuration
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXLarge = 30.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;

  // Image Sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 56.0;
  static const double avatarSizeLarge = 96.0;

  // Animation Configuration
  static const double blurSigma = 10.0;
  static const double glassOpacity = 0.4;

  // Database Configuration
  static const int databaseVersion = 2;
  static const String databaseName = 'bilgi_avcisi.db';

  // Notification Configuration
  static const String notificationChannelId = 'bilgi_avcisi_channel';
  static const String notificationChannelName = 'Bilgi Avcısı Bildirimleri';

  // Grade Options
  static const List<String> grades = [
    '3. Sınıf',
    '4. Sınıf',
    '5. Sınıf',
    '6. Sınıf',
    '7. Sınıf',
    '8. Sınıf',
  ];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int minAge = 6;
  static const int maxAge = 18;

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;

  // Asset Paths
  static const String assetsImagesPath = 'assets/images/';
  static const String assetsAnimationsPath = 'assets/animation/';
  static const String assetsJsonPath = 'assets/json/';

  // Default Values
  static const String defaultAvatar = 'assets/images/avatar.png';
  static const String defaultGrade = '3. Sınıf';
}
