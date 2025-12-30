// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'dart:async';
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
/// 🏆 THE GOLDEN BOSS CARD - Haftalık Sınav Widget'ı
/// ═══════════════════════════════════════════════════════════════════════════
/// Ekrandaki en değerli, en ihtişamlı kart.
/// Altın gradyanı, Lottie animasyonu ve nefes alan efektlerle.
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyExamCard extends ConsumerStatefulWidget {
  const WeeklyExamCard({super.key});

  @override
  ConsumerState<WeeklyExamCard> createState() => _WeeklyExamCardState();
}

class _WeeklyExamCardState extends ConsumerState<WeeklyExamCard>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // SERVICES & STATE (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  final WeeklyExamService _examService = WeeklyExamService();

  WeeklyExam? _exam;
  ExamRoomStatus _status = ExamRoomStatus.beklemede;
  bool _hasCompleted = false;
  WeeklyExamResult? _userResult;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isLoading = true;

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON KONTROLCÜLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // ─────────────────────────────────────────────────────────────────────────
  // RENKLENDİRME PALETİ
  // ─────────────────────────────────────────────────────────────────────────
  // Aktif: Altın Sarısı -> Turuncu
  static const Color _goldStart = Color(0xFFFFD700);
  static const Color _goldEnd = Color(0xFFFF8C00);

  // Tamamlandı: Zümrüt Yeşili
  static const Color _emeraldStart = Color(0xFF10B981);
  static const Color _emeraldEnd = Color(0xFF059669);

  // Kilitli/Beklemede: Metalik Gri
  static const Color _metalStart = Color(0xFF6B7280);
  static const Color _metalEnd = Color(0xFF4B5563);

  // Sonuçlanmış: Mor
  static const Color _purpleStart = Color(0xFF8B5CF6);
  static const Color _purpleEnd = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadExamData();
    _startTimer();
  }

  void _initAnimations() {
    // Nefes alma efekti (sürekli)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Pulse efekti (BAŞLA butonu için)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Shimmer efekti
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
      if (_exam != null && !_isLoading) {
        _updateStatus();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERİ YÜKLEME (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadExamData() async {
    setState(() => _isLoading = true);

    try {
      final exam = await _examService.loadWeeklyExam();

      if (exam != null && mounted) {
        final hasCompleted = await _examService.hasUserCompletedExam(
          exam.examId,
        );
        final result = hasCompleted
            ? await _examService.getUserExamResult(exam.examId)
            : null;

        if (mounted) {
          setState(() {
            _exam = exam;
            _hasCompleted = hasCompleted;
            _userResult = result;
            _isLoading = false;
          });
          _updateStatus();
        }

        if (kDebugMode) {
          debugPrint(
            'Sınav yüklendi: ${exam.examId}, Tamamlandı: $hasCompleted',
          );
        }
      } else {
        setState(() {
          _exam = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sınav yükleme hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateStatus() {
    if (_exam == null) return;

    final weekStart = _examService.getThisWeekMonday();
    final newStatus = _examService.getExamStatus(weekStart);
    final remaining = _examService.getTimeRemaining(weekStart, newStatus);

    if (mounted) {
      setState(() {
        _status = newStatus;
        _remaining = remaining;
      });
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

    // Yükleniyor durumu
    if (_isLoading) {
      return _buildLoadingCard();
    }

    // Sınav yoksa
    if (_exam == null) {
      return _buildNoExamCard(isTablet);
    }

    // Ana kart
    return _buildGoldenBossCard(isTablet);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOADING CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _goldStart.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Haftalık sınav yükleniyor...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().shimmer(duration: 1500.ms, color: Colors.white24);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // THE GOLDEN BOSS CARD 🏆
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGoldenBossCard(bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive boyutlar
    final cardHeight = isTablet ? 180.0 : 165.0;
    final lottieSize = isTablet ? 80.0 : (screenWidth * 0.18).clamp(55.0, 70.0);
    // Lottie'nin kapladığı alan için padding hesapla
    final contentPaddingRight = lottieSize * 0.5 + 8;

    return AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            // Nefes alma efekti - çok hafif scale
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
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getMainColor().withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _getMainColor().withOpacity(0.3),
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
                    // ═══ KATMAN 0: Glass overlay ═══
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

                    // ═══ KATMAN 1: Lottie Animasyonu (Sağ Taraf) ═══
                    Positioned(
                      right: -5,
                      bottom: 5,
                      child: Opacity(
                        opacity: 0.85,
                        child: SizedBox(
                          width: lottieSize,
                          height: lottieSize,
                          child: Lottie.asset(
                            'assets/animation/card_thoropy.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ),
                    ),

                    // ═══ KATMAN 2: Dekoratif Daireler ═══
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

                    // ═══ KATMAN 3: Ana İçerik ═══
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
                          // ─── Etiket: "TÜRKİYE GENELİ" ───
                          Flexible(
                            flex: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _hasCompleted
                                        ? Icons.check_circle
                                        : Icons.emoji_events,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _hasCompleted
                                          ? 'TAMAMLANDI'
                                          : 'TÜRKİYE GENELİ',
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
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ─── Başlık ───
                          Flexible(
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
                          ),

                          const SizedBox(height: 2),

                          // ─── Alt Başlık ───
                          Flexible(
                            flex: 0,
                            child: Text(
                              _exam?.description ??
                                  'Tüm derslerden karma sorularla kendini sına!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 10,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const Spacer(),

                          // ─── Alt Kısım: Sayaç/Skor + Buton ───
                          SizedBox(
                            height: 28,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Sayaç veya Puan
                                Flexible(
                                  flex: 1,
                                  child: _buildCounterOrScore(),
                                ),

                                // BAŞLA Butonu (Aktifse)
                                if (_canTakeAction()) ...[
                                  const SizedBox(width: 6),
                                  _buildStartButton(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ═══ KATMAN 4: Shimmer Efekti ═══
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment(
                                  -1 + _shimmerController.value * 3,
                                  -1,
                                ),
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
  // SAYAÇ VEYA SKOR WIDGET'I
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCounterOrScore() {
    // Tamamlandıysa puan göster - tek satır
    if (_hasCompleted && _userResult != null) {
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
              '${_userResult!.puan ?? 0} puan',
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

    // Aktifse geri sayım göster - tek satır
    if (_status != ExamRoomStatus.sonuclanmis) {
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
              _status == ExamRoomStatus.aktif
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

  // ─────────────────────────────────────────────────────────────────────────
  // BAŞLA BUTONU (Pulse Animasyonu ile)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStartButton() {
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
                  _getShortButtonText(),
                  style: TextStyle(
                    color: _getMainColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(_getButtonIcon(), size: 12, color: _getMainColor()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getShortButtonText() {
    if (_hasCompleted) {
      if (_status == ExamRoomStatus.sonuclanmis) return 'Gör';
      return '';
    }
    switch (_status) {
      case ExamRoomStatus.beklemede:
        return '';
      case ExamRoomStatus.aktif:
        return 'Git';
      case ExamRoomStatus.kapali:
        return '';
      case ExamRoomStatus.sonuclanmis:
        return 'Gör';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SINAV YOK KARTI
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNoExamCard(bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = isTablet ? 160.0 : 140.0;
    final lottieSize = isTablet ? 80.0 : (screenWidth * 0.18).clamp(55.0, 70.0);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_metalStart, _metalEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: _metalStart.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Lottie (soluk)
                Positioned(
                  right: -10,
                  bottom: 5,
                  child: Opacity(
                    opacity: 0.3,
                    child: SizedBox(
                      width: lottieSize,
                      height: lottieSize,
                      child: Lottie.asset(
                        'assets/animation/card_thoropy.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                ),

                // İçerik
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: lottieSize * 0.5 + 8,
                    top: 12,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Etiket
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy,
                              color: Colors.white70,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'YAKINDA',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Başlık
                      Text(
                        '🏆 Türkiye Geneli Deneme',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Hafta bilgisi
                      Text(
                        _examService.generateRoomName(
                          _examService.getThisWeekMonday(),
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Bilgilendirme mesajı
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sınav henüz yayınlanmadı 📚',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 600.ms);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI METODLAR (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────

  bool _canTakeAction() {
    if (_isLoading || _exam == null) return false;

    if (_hasCompleted && _status == ExamRoomStatus.sonuclanmis) {
      return true;
    }

    if (_hasCompleted) {
      return false;
    }

    if (_status == ExamRoomStatus.aktif) {
      return true;
    }

    if (_status == ExamRoomStatus.sonuclanmis) {
      return true;
    }

    return false;
  }

  LinearGradient _getGradient() {
    // Tamamlandı ve sonuçlar açıklanmadı
    if (_hasCompleted && _status != ExamRoomStatus.sonuclanmis) {
      return LinearGradient(
        colors: [_emeraldStart, _emeraldEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    switch (_status) {
      case ExamRoomStatus.beklemede:
        return LinearGradient(
          colors: [_metalStart, _metalEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ExamRoomStatus.aktif:
        return LinearGradient(
          colors: [_goldStart, _goldEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ExamRoomStatus.kapali:
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ExamRoomStatus.sonuclanmis:
        return LinearGradient(
          colors: [_purpleStart, _purpleEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getMainColor() {
    if (_hasCompleted && _status != ExamRoomStatus.sonuclanmis) {
      return _emeraldStart;
    }

    switch (_status) {
      case ExamRoomStatus.beklemede:
        return _metalStart;
      case ExamRoomStatus.aktif:
        return _goldEnd;
      case ExamRoomStatus.kapali:
        return Colors.orange.shade600;
      case ExamRoomStatus.sonuclanmis:
        return _purpleStart;
    }
  }

  IconData _getButtonIcon() {
    if (_hasCompleted) {
      if (_status == ExamRoomStatus.sonuclanmis) {
        return Icons.visibility;
      }
      return Icons.hourglass_empty;
    }

    switch (_status) {
      case ExamRoomStatus.beklemede:
        return Icons.lock_clock;
      case ExamRoomStatus.aktif:
        return Icons.arrow_forward;
      case ExamRoomStatus.kapali:
        return Icons.lock;
      case ExamRoomStatus.sonuclanmis:
        return Icons.leaderboard;
    }
  }

  void _onCardTap() {
    if (_exam == null) return;

    // ÖNCELİK 1: Sınav tamamlandıysa ve sonuçlar HENÜZ açıklanmadıysa -> ENGELLE
    if (_hasCompleted && _status != ExamRoomStatus.sonuclanmis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.hourglass_top, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu sınavı zaten tamamladın! Sonuçlar Pazar 12:00\'da açıklanacak.',
                ),
              ),
            ],
          ),
          backgroundColor: _emeraldEnd,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ÖNCELİK 2: Sonuçlar açıklandıysa sonuç ekranına git
    if (_status == ExamRoomStatus.sonuclanmis) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WeeklyExamResultScreen(exam: _exam!, result: _userResult),
        ),
      );
      return;
    }

    // Sınav aktif ve kullanıcı henüz çözmemişse sınav ekranına git
    if (_status == ExamRoomStatus.aktif && !_hasCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WeeklyExamScreen(exam: _exam!)),
      ).then((_) {
        _loadExamData();
      });
      return;
    }

    // Beklemede veya kapalı ise bilgi göster
    if (_status == ExamRoomStatus.beklemede) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.schedule, color: Colors.white),
              SizedBox(width: 12),
              Text('Sınav henüz başlamadı. Pazartesi başlayacak!'),
            ],
          ),
          backgroundColor: _metalEnd,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_status == ExamRoomStatus.kapali && !_hasCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu haftaki sınavı kaçırdın 😔 Gelecek hafta bekleriz!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_hasCompleted && _status != ExamRoomStatus.sonuclanmis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.hourglass_top, color: Colors.white),
              SizedBox(width: 12),
              Text('Sonuçlar Pazar 12:00\'da açıklanacak!'),
            ],
          ),
          backgroundColor: _emeraldEnd,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
