import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// In-App Bildirim Overlay'i
/// Uygulama ön plandayken kullanıcıya görünür bildirim gösterir
class InAppNotification extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Duration duration;
  final IconData icon;
  final List<Color> gradientColors;

  const InAppNotification({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    this.duration = const Duration(seconds: 5),
    this.icon = Icons.celebration,
    this.gradientColors = const [Color(0xFF667EEA), Color(0xFF764BA2)],
  });

  @override
  State<InAppNotification> createState() => _InAppNotificationState();

  /// In-app bildirim göster
  static void show(
    BuildContext context, {
    required String title,
    required String body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
    IconData icon = Icons.celebration,
    List<Color> gradientColors = const [Color(0xFF667EEA), Color(0xFF764BA2)],
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _InAppNotificationOverlay(
        title: title,
        body: body,
        onTap: onTap,
        duration: duration,
        icon: icon,
        gradientColors: gradientColors,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _InAppNotificationState extends State<InAppNotification> {
  @override
  Widget build(BuildContext context) {
    return _buildNotificationCard();
  }

  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.body,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InAppNotificationOverlay extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Duration duration;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onDismiss;

  const _InAppNotificationOverlay({
    required this.title,
    required this.body,
    this.onTap,
    required this.duration,
    required this.icon,
    required this.gradientColors,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<_InAppNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late Timer _dismissTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_isVisible) {
      setState(() => _isVisible = false);
      Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
    }
  }

  void _onTap() {
    _dismissTimer.cancel();
    widget.onTap?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 0,
      right: 0,
      child:
          AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isVisible ? 1.0 : 0.0,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! < 0) {
                      _dismiss();
                    }
                  },
                  child: InAppNotification(
                    title: widget.title,
                    body: widget.body,
                    onTap: _onTap,
                    duration: widget.duration,
                    icon: widget.icon,
                    gradientColors: widget.gradientColors,
                  ),
                ),
              )
              .animate(target: _isVisible ? 1 : 0)
              .slideY(
                begin: -1,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms),
    );
  }
}

/// Hoşgeldin bildirimi için yardımcı fonksiyon
void showWelcomeNotification(BuildContext context, String userName) {
  // Komik ve samimi hoşgeldin mesajları
  final messages = [
    {
      'title': '🎉 Eyyy $userName! Hoş geldin!',
      'body': 'Sonunda geldin be! Seni beklerken maskotumuz uyuyakalmış 😴',
    },
    {
      'title': '🚀 $userName kabinimize hoş geldin!',
      'body': 'Kemer takmayı unutma, bilgi yolculuğumuz bumpy olabilir! 🎢',
    },
    {
      'title': '🌟 Aa $userName gelmiş!',
      'body': 'Tam seni düşünüyorduk! Kulakların çınlamadı mı? 👂✨',
    },
    {
      'title': '🎮 Level 1: $userName Başlasın!',
      'body': 'Oyuna hazır mısın? Spoiler: Bu oyunda herkes kazanıyor! 🏆',
    },
    {
      'title': '📚 $userName\'in Macerası Başlıyor!',
      'body': 'Kitap kurdumuz uyanmış! Okumaya değil, oynamaya hazır ol! 🐛',
    },
  ];

  // Rastgele bir mesaj seç
  final randomIndex = DateTime.now().millisecondsSinceEpoch % messages.length;
  final message = messages[randomIndex];

  InAppNotification.show(
    context,
    title: message['title']!,
    body: message['body']!,
    icon: Icons.celebration,
    gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
    duration: const Duration(seconds: 6),
  );
}
