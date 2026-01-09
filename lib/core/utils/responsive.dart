import 'package:flutter/material.dart';

/// 📱 Responsive Helper - Ekran boyutuna göre adaptif tasarım
///
/// Extension metotları ile kolay kullanım:
/// ```dart
/// if (context.isTablet) {
///   // Tablet layout
/// }
///
/// final padding = context.responsiveValue(
///   phone: 16.0,
///   tablet: 24.0,
///   desktop: 32.0,
/// );
/// ```

/// Ekran boyutu breakpoint'leri
class ScreenBreakpoints {
  ScreenBreakpoints._();

  /// Telefon max genişliği
  static const double phoneMaxWidth = 600;

  /// Tablet max genişliği
  static const double tabletMaxWidth = 1200;

  /// Küçük telefon max genişliği
  static const double smallPhoneMaxWidth = 360;

  /// Küçük telefon max yüksekliği (iPhone SE gibi)
  static const double smallPhoneMaxHeight = 700;
}

/// Cihaz türü enum
enum DeviceType { smallPhone, phone, tablet, desktop }

/// BuildContext extension - responsive helper metodları
extension ResponsiveExtension on BuildContext {
  /// Ekran genişliği
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Ekran yüksekliği
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Cihaz türü
  DeviceType get deviceType {
    final width = screenWidth;
    if (width <= ScreenBreakpoints.smallPhoneMaxWidth) {
      return DeviceType.smallPhone;
    } else if (width <= ScreenBreakpoints.phoneMaxWidth) {
      return DeviceType.phone;
    } else if (width <= ScreenBreakpoints.tabletMaxWidth) {
      return DeviceType.tablet;
    }
    return DeviceType.desktop;
  }

  /// Küçük telefon mu? (iPhone SE, küçük Android)
  bool get isSmallPhone => deviceType == DeviceType.smallPhone;

  /// Telefon mu?
  bool get isPhone =>
      deviceType == DeviceType.phone || deviceType == DeviceType.smallPhone;

  /// Tablet mi?
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Masaüstü mü?
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Tablet veya daha büyük mü?
  bool get isTabletOrLarger =>
      deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;

  /// Landscape modda mı?
  bool get isLandscape => screenWidth > screenHeight;

  /// Portrait modda mı?
  bool get isPortrait => screenHeight > screenWidth;

  /// Ekran yüksekliği küçük mü? (keyboard açık veya küçük cihaz)
  bool get isShortScreen =>
      screenHeight < ScreenBreakpoints.smallPhoneMaxHeight;

  /// Responsive değer seçici
  ///
  /// Cihaz türüne göre uygun değeri döndürür:
  /// ```dart
  /// final fontSize = context.responsiveValue(
  ///   phone: 14.0,
  ///   tablet: 16.0,
  ///   desktop: 18.0,
  /// );
  /// ```
  T responsiveValue<T>({
    required T phone,
    T? smallPhone,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return smallPhone ?? phone;
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }

  /// Responsive padding
  EdgeInsets get responsivePadding => responsiveValue(
    smallPhone: const EdgeInsets.all(12),
    phone: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(24),
    desktop: const EdgeInsets.all(32),
  );

  /// Responsive horizontal padding
  double get responsiveHorizontalPadding => responsiveValue(
    smallPhone: 12.0,
    phone: 16.0,
    tablet: 24.0,
    desktop: 32.0,
  );

  /// Grid column sayısı
  int get gridColumnCount =>
      responsiveValue(smallPhone: 1, phone: 2, tablet: 3, desktop: 4);

  /// Card genişlik oranı (ekran genişliğine göre)
  double get cardWidthRatio =>
      responsiveValue(phone: 0.9, tablet: 0.7, desktop: 0.5);

  /// Max içerik genişliği (geniş ekranlarda içeriği sınırla)
  double get maxContentWidth =>
      responsiveValue(phone: double.infinity, tablet: 800.0, desktop: 1000.0);
}

/// Responsive widget - child'ı cihaz türüne göre sarar
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.phone,
    this.smallPhone,
    this.tablet,
    this.desktop,
  });

  final Widget phone;
  final Widget? smallPhone;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    switch (context.deviceType) {
      case DeviceType.smallPhone:
        return smallPhone ?? phone;
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }
}

/// Centered max-width container - geniş ekranlarda içeriği ortalar
class CenteredMaxWidth extends StatelessWidget {
  const CenteredMaxWidth({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
