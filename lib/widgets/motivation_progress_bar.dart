import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/repository_providers.dart';

/// 🚀 Motivasyonel Yatay Progress Bar - Modern & Şık Tasarım
///
/// Header ile WeeklyExam kartı arasında yer alır.
/// Her açılışta soldan sağa animasyonlu dolum efekti.
class MotivationProgressBar extends ConsumerStatefulWidget {
  const MotivationProgressBar({super.key});

  @override
  ConsumerState<MotivationProgressBar> createState() =>
      _MotivationProgressBarState();
}

class _MotivationProgressBarState extends ConsumerState<MotivationProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _returnController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  late Animation<double> _fillAnimation;
  late Animation<double> _returnAnimation;
  late Animation<double> _shimmerAnimation;

  double _targetProgress = 0.0;
  int _displayedCompleted = 0;
  int _targetCompleted = 0;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    // Fill animasyonu (0 -> 100%)
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Return animasyonu (100% -> gerçek değer)
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Shimmer efekti
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Bounce efekti
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _returnAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.easeInOutCubic),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Fill bittikten sonra return başlasın
    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _returnController.forward(from: 0.0);
      }
    });

    // Return bittikten sonra bounce
    _returnController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _bounceController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _fillController.dispose();
    _returnController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider'ları yenile - her görünümde güncel veri al
    ref.invalidate(totalContentCountProvider);
    ref.invalidate(completedContentCountProvider);
    // Her ekran açılışında animasyonu sıfırla ve yeniden başlat
    _resetAndTriggerAnimation();
  }

  void _resetAndTriggerAnimation() {
    _hasAnimated = false;
    _displayedCompleted = 0;
    _fillController.reset();
    _returnController.reset();
    _bounceController.reset();
  }

  void _startFillAndReturnAnimation(double progress, int completed) {
    _targetProgress = progress;
    _targetCompleted = completed;

    // Sayı animasyonu listener
    void updateDisplayedCount() {
      if (!mounted) return;

      double animProgress;
      if (_fillController.isAnimating) {
        // Fill aşamasında: 0 -> completed
        animProgress = _fillAnimation.value;
        setState(() {
          _displayedCompleted = (completed * animProgress).round();
        });
      } else if (_returnController.isAnimating) {
        // Return aşamasında: sabit kal
        setState(() {
          _displayedCompleted = completed;
        });
      }
    }

    _fillController.addListener(updateDisplayedCount);
    _returnController.addListener(() {
      if (mounted) setState(() {});
    });

    _fillController.forward(from: 0.0);
    _hasAnimated = true;
  }

  double _getCurrentProgress() {
    if (_fillController.isAnimating) {
      // Fill aşaması: 0 -> 100%
      return _fillAnimation.value;
    } else if (_returnController.isAnimating) {
      // Return aşaması: 100% -> gerçek değer
      final returnValue = _returnAnimation.value;
      return _targetProgress + (1.0 - _targetProgress) * returnValue;
    } else if (_hasAnimated) {
      // Animasyon bitti, gerçek değer
      return _targetProgress;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(totalContentCountProvider);
    final completedAsync = ref.watch(completedContentCountProvider);

    final total = totalAsync.valueOrNull ?? 0;
    final completed = completedAsync.valueOrNull ?? 0;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    // İlk açılışta veya değer değiştiğinde animasyonu başlat
    if (total > 0 && (!_hasAnimated || _targetCompleted != completed)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_fillController.isAnimating &&
            !_returnController.isAnimating) {
          _startFillAndReturnAnimation(progress, completed);
        }
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D1B69).withValues(alpha: 0.9),
            const Color(0xFF11998E).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11998E).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF2D1B69).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık satırı
          _buildHeader(total, completed),

          const SizedBox(height: 10),

          // Progress bar
          _buildProgressBar(progress, completed),

          const SizedBox(height: 8),

          // Alt satır - Toplam içerik sayısı
          _buildFooter(total),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildHeader(int total, int completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // İnce ayar: İçeriği ortala
      children: [
        // Lottie kupa animasyonu
        SizedBox(
          width: 50,
          height: 50,
          // ✅ Lottie optimize edildi
          child: Lottie.asset(
            'assets/animation/card_thoropy.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            frameRate: FrameRate.max,
            options: LottieOptions(enableMergePaths: true),
          ),
        ),

        const SizedBox(width: 10),

        // Motivasyon metni
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Metinler sola hizalı kalsın (ikonun yanında)
            children: [
              const Text(
                'Harika Gidiyorsun! 💪',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Keşfedilecek binlerce içerik seni bekliyor!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, int completed) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Animasyonlu dolum
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _returnController]),
            builder: (context, child) {
              final animatedProgress = _getCurrentProgress();
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedProgress.clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00F260),
                        Color(0xFF0575E6),
                        Color(0xFFa855f7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F260).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Shimmer efekti
          AnimatedBuilder(
            animation: Listenable.merge([
              _shimmerAnimation,
              _fillController,
              _returnController,
            ]),
            builder: (context, child) {
              final currentProgress = _getCurrentProgress();
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: currentProgress.clamp(0.02, 1.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // Çözülen sayı göstergesi (ortada)
          Center(
            child: Text(
              '$_displayedCompleted çözüldü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.2, // İnce ayar: Dikey ortalama performansı için
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$total İçerik',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
