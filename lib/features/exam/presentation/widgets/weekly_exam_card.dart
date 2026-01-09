// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../data/weekly_exam_service.dart';
import '../../domain/models/weekly_exam.dart';
import '../screens/weekly_exam_screen.dart';
import '../screens/weekly_exam_result_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏆 TÜRKİYE GENELİ DENEME KARTI
/// ═══════════════════════════════════════════════════════════════════════════
///
/// HAFTALIK DÖNGÜ:
/// ┌─────────────────────────────────────────────────────────────────────────┐
/// │ PAZARTESİ 00:00 ──► PERŞEMBE 23:59  │ YAYIN (Sarı Kart)                 │
/// │ CUMA 00:00 ────────► CUMARTESİ 11:59 │ SONUÇ BEKLENİYOR                  │
/// │ CUMARTESİ 12:00 ──► PAZAR 23:59     │ SONUÇLAR YAYINDA (Mor)            │
/// └─────────────────────────────────────────────────────────────────────────┘
///
/// 7 DURUM:
/// 1. yukleniyor - Veriler yükleniyor (gri)
/// 2. yakinda - Sınav henüz yayınlanmadı (gri)
/// 3. yayinda - Sınav yayında, kullanıcı girebilir (sarı)
/// 4. tamampiSonucBekliyor - Tamamlandı, sonuç bekleniyor (yeşil)
/// 5. kacpipidin - Sınava giriş süresi geçti (turuncu)
/// 6. sonuclarAciklandi - Sonuçlar açıklandı (mor)
/// 7. onceSonucuGor - Önceki sonucu görmelisiniz (kırmızı)
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyExamCard extends ConsumerStatefulWidget {
  const WeeklyExamCard({super.key});

  @override
  ConsumerState<WeeklyExamCard> createState() => _WeeklyExamCardState();
}

class _WeeklyExamCardState extends ConsumerState<WeeklyExamCard>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // SERVICES & STATE
  // ─────────────────────────────────────────────────────────────────────────
  final WeeklyExamService _examService = WeeklyExamService();

  WeeklyExam? _exam;
  WeeklyExamResult? _currentResult;
  WeeklyExamResult? _unviewedResult;
  ExamCardStatus _status = ExamCardStatus.yukleniyor;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON KONTROLCÜLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _startTimer();
  }

  void _initAnimations() {
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breatheController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateStatus();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERİ YÜKLEME
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _status = ExamCardStatus.yukleniyor);

    try {
      // 1. Bu haftanın sınavını yükle
      final exam = await _examService.loadCurrentWeekExam();

      // 2. Görüntülenmemiş sonuç var mı kontrol et
      final unviewedResult = await _examService.getUnviewedResult();

      // 3. Eğer sınav varsa, bu sınavın sonucunu al
      WeeklyExamResult? currentResult;
      if (exam != null) {
        currentResult = await _examService.getUserExamResult(exam.examId);
      }

      // 4. Kart durumunu hesapla
      final status = await _examService.getCardStatus(
        currentExam: exam,
        currentResult: currentResult,
        previousUnviewedResult: unviewedResult,
      );

      if (mounted) {
        setState(() {
          _exam = exam;
          _currentResult = currentResult;
          _unviewedResult = unviewedResult;
          _status = status;
        });
        _updateRemaining();
      }

      if (kDebugMode) {
        debugPrint('📌 Kart durumu: $_status');
        debugPrint('📌 Sınav: ${exam?.examId ?? "yok"}');
        debugPrint('📌 Mevcut sonuç: ${currentResult?.examId ?? "yok"}');
        debugPrint('📌 Görüntülenmemiş: ${unviewedResult?.examId ?? "yok"}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Veri yükleme hatası: $e');
      if (mounted) {
        setState(() => _status = ExamCardStatus.yakinda);
      }
    }
  }

  Future<void> _updateStatus() async {
    if (!mounted) return;

    final status = await _examService.getCardStatus(
      currentExam: _exam,
      currentResult: _currentResult,
      previousUnviewedResult: _unviewedResult,
    );

    if (mounted && status != _status) {
      setState(() => _status = status);
    }

    _updateRemaining();
  }

  void _updateRemaining() {
    DateTime? examWeekStart;
    if (_exam != null) {
      try {
        examWeekStart = DateTime.parse(_exam!.weekStart);
      } catch (e) {
        // ignore
      }
    }

    final remaining = _examService.getTimeRemaining(_status, examWeekStart);

    if (mounted) {
      setState(() => _remaining = remaining);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '$days gün ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return _buildCard(isTablet);
  }

  Widget _buildCard(bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = isTablet ? 180.0 : 165.0;
    final lottieSize = isTablet ? 80.0 : (screenWidth * 0.18).clamp(55.0, 70.0);
    final contentPaddingRight = lottieSize * 0.5 + 8;

    return AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            final breatheScale = 1.0 + (_breatheController.value * 0.008);
            return Transform.scale(scale: breatheScale, child: child);
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _onCardTap();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: cardHeight,
              decoration: BoxDecoration(
                gradient: _status.gradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _status.primaryColor.withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _status.primaryColor.withOpacity(0.3),
                    blurRadius: 50,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Glass overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Lottie Animasyonu
                    Positioned(
                      right: -5,
                      bottom: 5,
                      child: Opacity(
                        opacity: _status == ExamCardStatus.yukleniyor
                            ? 0.3
                            : 0.85,
                        // ✅ Lottie optimize edildi
                        child: SizedBox(
                          width: lottieSize,
                          height: lottieSize,
                          child: Lottie.asset(
                            'assets/animation/card_thoropy.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: _status != ExamCardStatus.yukleniyor,
                            frameRate: FrameRate.max,
                            options: LottieOptions(enableMergePaths: true),
                          ),
                        ),
                      ),
                    ),

                    // Dekoratif Daireler
                    Positioned(
                      left: -40,
                      bottom: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60,
                      top: -30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),

                    // Ana İçerik
                    Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: contentPaddingRight,
                        top: 12,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Etiket
                          _buildStatusLabel(),

                          const SizedBox(height: 6),

                          // Başlık
                          _buildTitle(isTablet),

                          const SizedBox(height: 2),

                          // Alt Başlık / Mesaj
                          _buildSubtitle(),

                          const Spacer(),

                          // Alt Kısım: Sayaç + Buton
                          _buildBottomRow(),
                        ],
                      ),
                    ),

                    // Shimmer Efekti
                    if (_status == ExamCardStatus.yayinda ||
                        _status == ExamCardStatus.onceSonucuGor)
                      _buildShimmerEffect(),

                    // Yükleniyor göstergesi
                    if (_status == ExamCardStatus.yukleniyor)
                      Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 600.ms)
        .shimmer(delay: 300.ms, duration: 1500.ms, color: Colors.white24);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET BİLEŞENLERİ
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatusLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_status.icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _status.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Flexible(
      flex: 0,
      child: Text(
        _exam?.title ?? '🏆 Türkiye Geneli Deneme',
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 17 : 14,
          fontWeight: FontWeight.bold,
          height: 1.1,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtitle() {
    String message;

    switch (_status) {
      case ExamCardStatus.yukleniyor:
        message = 'Yükleniyor...';
        break;
      case ExamCardStatus.yakinda:
        message = 'Sınav henüz yayınlanmadı. Pazartesi başlayacak!';
        break;
      case ExamCardStatus.yayinda:
        message = _exam?.description ?? 'Hemen başla ve kendini test et!';
        break;
      case ExamCardStatus.tamampiSonucBekliyor:
        message = 'Sonuçlar Cumartesi 12:00\'de açıklanacak';
        break;
      case ExamCardStatus.kacpipidin:
        message = 'Bu haftaki sınavı kaçırdın 😔 Gelecek hafta bekleriz!';
        break;
      case ExamCardStatus.sonuclarAciklandi:
        message = 'Sonuçlar açıklandı! Tıkla ve gör.';
        break;
      case ExamCardStatus.onceSonucuGor:
        message = '⚠️ Önce önceki sınavının sonucunu görmelisin!';
        break;
    }

    return Flexible(
      flex: 0,
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 10,
          height: 1.1,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBottomRow() {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sayaç veya Puan
          Flexible(flex: 1, child: _buildCounterOrScore()),

          // Aksiyon Butonu
          if (_hasAction()) ...[const SizedBox(width: 6), _buildActionButton()],
        ],
      ),
    );
  }

  Widget _buildCounterOrScore() {
    // Sonuç varsa ve sonuçlar açıklandıysa puan göster
    // NOT: tamampiSonucBekliyor durumunda puan GÖSTERİLMEZ - kullanıcı tıklayarak içeri girmeli
    if (_currentResult != null && _status == ExamCardStatus.sonuclarAciklandi) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '${_currentResult!.puan ?? 0} puan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Geri sayım göster
    if (_status == ExamCardStatus.yayinda ||
        _status == ExamCardStatus.tamampiSonucBekliyor ||
        _status == ExamCardStatus.yakinda ||
        _status == ExamCardStatus.kacpipidin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _status == ExamCardStatus.yayinda
                  ? Icons.timer
                  : Icons.hourglass_top,
              color: Colors.white.withOpacity(0.9),
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDuration(_remaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.05);
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _onCardTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _status.buttonText,
                  style: TextStyle(
                    color: _status.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(_getButtonIcon(), size: 12, color: _status.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1 + _shimmerController.value * 3, -1),
                end: Alignment(_shimmerController.value * 3, 1),
                colors: const [
                  Colors.transparent,
                  Color(0x15FFFFFF),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI METODLAR
  // ─────────────────────────────────────────────────────────────────────────
  bool _hasAction() {
    switch (_status) {
      case ExamCardStatus.yukleniyor:
      case ExamCardStatus.yakinda:
      case ExamCardStatus.kacpipidin:
        return false;
      case ExamCardStatus.yayinda:
      case ExamCardStatus.tamampiSonucBekliyor:
      case ExamCardStatus.sonuclarAciklandi:
      case ExamCardStatus.onceSonucuGor:
        return true;
    }
  }

  IconData _getButtonIcon() {
    switch (_status) {
      case ExamCardStatus.yukleniyor:
        return Icons.hourglass_empty;
      case ExamCardStatus.yakinda:
        return Icons.lock_clock;
      case ExamCardStatus.yayinda:
        return Icons.arrow_forward;
      case ExamCardStatus.tamampiSonucBekliyor:
        return Icons.hourglass_top;
      case ExamCardStatus.kacpipidin:
        return Icons.sentiment_dissatisfied;
      case ExamCardStatus.sonuclarAciklandi:
        return Icons.visibility;
      case ExamCardStatus.onceSonucuGor:
        return Icons.warning;
    }
  }

  void _onCardTap() {
    switch (_status) {
      case ExamCardStatus.yukleniyor:
        // Yükleniyor, bekle
        break;

      case ExamCardStatus.yakinda:
        _showSnackBar(
          'Sınav henüz başlamadı. Pazartesi başlayacak!',
          Icons.schedule,
          Colors.grey.shade700,
        );
        break;

      case ExamCardStatus.yayinda:
        // Sınava git
        if (_exam != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeeklyExamScreen(exam: _exam!),
            ),
          ).then((_) => _loadData());
        }
        break;

      case ExamCardStatus.tamampiSonucBekliyor:
        _showSnackBar(
          'Sınavı tamamladın! Sonuçlar Cumartesi 12:00\'de açıklanacak.',
          Icons.hourglass_top,
          Colors.green.shade600,
        );
        break;

      case ExamCardStatus.kacpipidin:
        _showSnackBar(
          'Bu haftaki sınavı kaçırdın 😔 Gelecek hafta bekleriz!',
          Icons.sentiment_dissatisfied,
          Colors.orange.shade700,
        );
        break;

      case ExamCardStatus.sonuclarAciklandi:
        // Sonuç ekranına git
        if (_exam != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WeeklyExamResultScreen(exam: _exam!, result: _currentResult),
            ),
          ).then((_) async {
            // Sonucu görüntülenmiş olarak işaretle
            if (_currentResult != null) {
              await _examService.markResultAsViewed(_currentResult!.examId);
            }
            _loadData();
          });
        }
        break;

      case ExamCardStatus.onceSonucuGor:
        // Görüntülenmemiş sonucu göster
        if (_unviewedResult != null) {
          _showUnviewedResultDialog();
        }
        break;
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showUnviewedResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 28),
            const SizedBox(width: 8),
            const Text('Sonucun Hazır!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Önceki sınavının sonucu açıklandı!',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆 ', style: TextStyle(fontSize: 24)),
                  Text(
                    '${_unviewedResult?.puan ?? 0} Puan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Doğru: ${_unviewedResult?.dogru ?? 0}  |  Yanlış: ${_unviewedResult?.yanlis ?? 0}  |  Boş: ${_unviewedResult?.bos ?? 0}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              // Sonucu görüntülenmiş olarak işaretle
              if (_unviewedResult != null) {
                await _examService.markResultAsViewed(_unviewedResult!.examId);
              }
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              // Sonucu görüntülenmiş olarak işaretle
              if (_unviewedResult != null) {
                await _examService.markResultAsViewed(_unviewedResult!.examId);
              }
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // İlgili sınavı getir ve detay ekranına git
              if (_unviewedResult != null) {
                final exam = await _examService.getExamById(
                  _unviewedResult!.examId,
                );
                if (!mounted) return;
                if (exam != null) {
                  // Detaylı sonuç ekranına git
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyExamResultScreen(
                        exam: exam,
                        result: _unviewedResult,
                      ),
                    ),
                  ).then((_) => _loadData());
                  return;
                }
              }
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Detayları Gör'),
          ),
        ],
      ),
    );
  }
}
