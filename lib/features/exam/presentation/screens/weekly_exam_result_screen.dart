// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/weekly_exam.dart';
import '../../data/weekly_exam_service.dart';
import '../../../../services/database_helper.dart';
import '../../../../services/local_preferences_service.dart';
import '../../../../screens/test_list_screen.dart';
import '../../../duel/presentation/screens/duel_game_selection_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 BİLGİ AVCISI - EXAM RESULT REPORT SCREEN
/// ═══════════════════════════════════════════════════════════════════════════
/// Modern Ed-Tech UI, Gamified Elements, Clean Typography, Vibrant Colors.
/// Yaş grubuna uyumlu (3-8. sınıf), Dark Mode destekli, Export-ready tasarım.
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyExamResultScreen extends StatefulWidget {
  final WeeklyExam exam;
  final WeeklyExamResult? result;

  const WeeklyExamResultScreen({super.key, required this.exam, this.result});

  @override
  State<WeeklyExamResultScreen> createState() => _WeeklyExamResultScreenState();
}

class _WeeklyExamResultScreenState extends State<WeeklyExamResultScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // SERVİS & STATE
  // ─────────────────────────────────────────────────────────────────────────
  final WeeklyExamService _examService = WeeklyExamService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalPreferencesService _prefsService = LocalPreferencesService();
  final GlobalKey _reportKey = GlobalKey(); // Export için

  // Dinamik konu isimleri - SQLite'dan yüklenecek
  Map<String, String> _topicNames = {};

  // Kullanıcı il/ilçe bilgileri - profil kurulumundan
  String _userCity = '';
  String _userDistrict = '';

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON KONTROLCÜLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 RENK PALETİ - MODERN ED-TECH UI
  // ─────────────────────────────────────────────────────────────────────────
  // Ana Renkler
  static const Color _primaryBlue = Color(0xFF4A90E2); // Trustworthy Blue
  static const Color _secondaryOrange = Color(0xFFF5A623); // Energetic Orange
  // ignore: unused_field - Gelecekte kullanılacak
  static const Color _deepPurple = Color(0xFF5B2C6F); // Deep Purple

  // Gradient Renkleri (Hero Area)
  static const Color _gradientStart = Color(0xFF1A237E); // Deep Blue
  static const Color _gradientMid = Color(0xFF4A148C); // Purple
  static const Color _gradientEnd = Color(0xFF311B92); // Deep Purple

  // Durum Renkleri
  static const Color _successGreen = Color(0xFF27AE60); // Doğru - Yeşil
  static const Color _errorRed = Color(0xFFE74C3C); // Yanlış - Kırmızı
  static const Color _neutralGray = Color(0xFF95A5A6); // Boş - Gri
  static const Color _warningOrange = Color(0xFFF39C12); // Uyarı - Turuncu

  // Ders Renkleri
  static const Color _mathColor = Color(0xFF3498DB); // Matematik - Mavi
  static const Color _turkishColor = Color(0xFFE74C3C); // Türkçe - Kırmızı
  static const Color _scienceColor = Color(0xFF2ECC71); // Fen - Yeşil
  static const Color _socialColor = Color(0xFF9B59B6); // Sosyal - Mor

  // Rozet Renkleri
  static const Color _goldBadge = Color(0xFFFFD700);
  static const Color _silverBadge = Color(0xFFC0C0C0);
  // ignore: unused_field - Gelecekte kullanılacak
  static const Color _bronzeBadge = Color(0xFFCD7F32);

  // Dark Mode Renkleri
  static const Color _darkBg = Color(0xFF1A1A2E);
  static const Color _darkCard = Color(0xFF16213E);
  static const Color _darkText = Color(0xFFE8E8E8);

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI FONKSİYONLAR
  // ─────────────────────────────────────────────────────────────────────────

  /// Sayıyı küsüratlı veya tam sayı olarak formatlar
  /// Eğer küsürat varsa 2 basamak gösterir, yoksa tam sayı gösterir
  static String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    } else {
      // Küsüratı 2 basamakla göster, sondaki sıfırları temizle
      final formatted = value.toStringAsFixed(2);
      // Sondaki gereksiz sıfırları temizle (örn: 3.50 → 3.5, 3.00 → 3)
      if (formatted.endsWith('0')) {
        final trimmed = formatted.replaceAll(RegExp(r'0+$'), '');
        return trimmed.endsWith('.')
            ? trimmed.substring(0, trimmed.length - 1)
            : trimmed;
      }
      return formatted;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DERS VERİLERİ (Simüle - Gerçek veriler modelden gelecek)
  // ─────────────────────────────────────────────────────────────────────────
  List<SubjectPerformance> get _subjectPerformances {
    // Sorulardan ders bazlı performans hesapla
    final subjects = <String, SubjectPerformance>{};

    for (int i = 0; i < widget.exam.questions.length; i++) {
      final question = widget.exam.questions[i];
      final lessonName = question.lessonName ?? 'Genel';
      final questionId = (i + 1).toString();
      final userAnswer = widget.result?.cevaplar[questionId];
      final isCorrect = userAnswer == question.correctAnswer;
      final isEmpty = userAnswer == null || userAnswer == 'EMPTY';

      if (!subjects.containsKey(lessonName)) {
        subjects[lessonName] = SubjectPerformance(
          name: lessonName,
          icon: _getSubjectIcon(lessonName),
          color: _getSubjectColor(lessonName),
          correct: 0,
          wrong: 0,
          empty: 0,
          totalQuestions: 0,
        );
      }

      final perf = subjects[lessonName]!;
      subjects[lessonName] = SubjectPerformance(
        name: perf.name,
        icon: perf.icon,
        color: perf.color,
        correct: perf.correct + (isCorrect ? 1 : 0),
        wrong: perf.wrong + (!isEmpty && !isCorrect ? 1 : 0),
        empty: perf.empty + (isEmpty ? 1 : 0),
        totalQuestions: perf.totalQuestions + 1,
      );
    }

    return subjects.values.toList();
  }

  IconData _getSubjectIcon(String lessonName) {
    final lower = lessonName.toLowerCase();
    if (lower.contains('matematik')) {
      return Icons.calculate;
    }
    if (lower.contains('türkçe')) {
      return Icons.menu_book;
    }
    if (lower.contains('fen')) {
      return Icons.science;
    }
    if (lower.contains('sosyal')) {
      return Icons.public;
    }
    if (lower.contains('din')) {
      return Icons.auto_stories;
    }
    if (lower.contains('ingilizce') || lower.contains('english')) {
      return Icons.language;
    }
    return Icons.school;
  }

  Color _getSubjectColor(String lessonName) {
    final lower = lessonName.toLowerCase();
    if (lower.contains('matematik')) {
      return _mathColor;
    }
    if (lower.contains('türkçe')) {
      return _turkishColor;
    }
    if (lower.contains('fen')) {
      return _scienceColor;
    }
    if (lower.contains('sosyal')) {
      return _socialColor;
    }
    if (lower.contains('din')) {
      return const Color(0xFF8E44AD);
    }
    if (lower.contains('ingilizce') || lower.contains('english')) {
      return const Color(0xFF1ABC9C);
    }
    return _primaryBlue;
  }

  @override
  void initState() {
    super.initState();

    // Konu isimlerini veritabanından yükle
    _loadTopicNames();

    // Kullanıcı il/ilçe bilgilerini profil kurulumundan yükle
    _loadUserLocation();

    // Sonuç görüntülendi olarak işaretle
    if (widget.result != null) {
      _examService.markResultAsViewed(widget.result!.examId);
    }

    // Konfeti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Skor animasyon controller
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final currentScore = (widget.result?.puan ?? 0).toDouble();

    _scoreAnimation = Tween<double>(begin: 0, end: currentScore).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Sonuçlar açıksa konfeti ve animasyonu başlat
    final weekStart = _examService.getThisWeekMonday();
    if (_examService.areResultsAvailable(weekStart) && widget.result != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
        _scoreAnimationController.forward();
      });
    }

    // Geri sayım timer'ı başlat
    _startCountdownTimer();
  }

  /// Veritabanından tüm konu isimlerini yükle (3-8. sınıflar için)
  Future<void> _loadTopicNames() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> results = await db.query('Konular');

      if (mounted) {
        setState(() {
          _topicNames = {
            for (var row in results)
              row['konuID'] as String: row['konuAdi'] as String,
          };
        });
      }
    } catch (e) {
      // Hata durumunda boş map kullan, topicId'ler olduğu gibi görünür
      if (mounted) {
        setState(() {
          _topicNames = {};
        });
      }
    }
  }

  /// Kullanıcı il/ilçe bilgilerini profil kurulumundan yükle
  Future<void> _loadUserLocation() async {
    try {
      final city = await _prefsService.getUserCity();
      final district = await _prefsService.getUserDistrict();

      if (mounted) {
        setState(() {
          _userCity = city ?? '';
          _userDistrict = district ?? '';
        });
      }
    } catch (e) {
      // Hata durumunda boş bırak
      debugPrint('❌ Kullanıcı konum bilgisi yüklenemedi: $e');
    }
  }

  void _startCountdownTimer() {
    final weekStart = _examService.getThisWeekMonday();
    _remainingTime = _examService.getTimeRemainingOld(
      weekStart,
      ExamRoomStatus.kapali,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remainingTime = _examService.getTimeRemainingOld(
            weekStart,
            ExamRoomStatus.kapali,
          );
        });
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAYLAŞIM FONKSİYONLARI
  // ─────────────────────────────────────────────────────────────────────────

  /// PDF rapor oluştur ve paylaş
  Future<void> _sharePdfReport() async {
    try {
      Navigator.pop(context); // Dialog'u kapat

      // PDF oluşturma animasyonu göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? _darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _primaryBlue),
                const SizedBox(height: 16),
                Text(
                  'PDF Rapor Hazırlanıyor...',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? _darkText
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Ekran görüntüsünü al
      await Future.delayed(const Duration(milliseconds: 300));
      final boundary =
          _reportKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Geçici dosyaya kaydet
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/sinav_raporu_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      Navigator.pop(context); // Loading dialog'unu kapat

      // Dosyayı paylaş
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Haftalık Sınav Raporum',
        text: 'Haftalık sınavımdan aldığım sonuçları sizlerle paylaşıyorum! 📊',
      );

      HapticFeedback.lightImpact();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Loading dialog'unu kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturulurken hata: $e'),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  /// Ekran görüntüsü çek ve paylaş
  Future<void> _takeScreenshot() async {
    try {
      Navigator.pop(context); // Dialog'u kapat

      // Ekran görüntüsü animasyonu
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? _darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _successGreen),
                const SizedBox(height: 16),
                Text(
                  'Ekran Görüntüsü Alınıyor...',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? _darkText
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Ekran görüntüsünü al
      await Future.delayed(const Duration(milliseconds: 300));
      final boundary =
          _reportKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Galeriye kaydet - Gal paketi kullanılıyor
      await Gal.putImageBytes(
        pngBytes,
        name: 'sinav_raporu_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      Navigator.pop(context);

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Ekran görüntüsü galeriye kaydedildi! 📸'),
            ],
          ),
          backgroundColor: _successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ekran görüntüsü alınırken hata: $e'),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final weekStart = _examService.getThisWeekMonday();
    final areResultsAvailable = _examService.areResultsAvailable(weekStart);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ═══ GRADIENT ARKA PLAN ═══
          _buildGradientBackground(isDarkMode),

          // ═══ ANA İÇERİK ═══
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                _buildTopBar(isDarkMode),

                // İçerik
                Expanded(
                  child: areResultsAvailable
                      ? _buildResultsContent(isDarkMode)
                      : _buildWaitingContent(isDarkMode),
                ),
              ],
            ),
          ),

          // ═══ KONFETİ ═══
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                _goldBadge,
                _secondaryOrange,
                Colors.white,
                _primaryBlue,
                _successGreen,
              ],
              numberOfParticles: 30,
              emissionFrequency: 0.05,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRADIENT ARKA PLAN
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGradientBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkBg, const Color(0xFF0F3460), _darkBg]
              : [_gradientStart, _gradientMid, _gradientEnd],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Dekoratif daireler
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_primaryBlue.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryOrange.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ÜST BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar(bool isDarkMode) {
    final weekStart = _examService.getThisWeekMonday();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildGlassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: isDarkMode ? _darkText : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  _examService.generateRoomName(weekStart),
                  style: TextStyle(
                    color: isDarkMode ? _darkText : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Türkiye Geneli Sonuç Raporu',
                  style: TextStyle(
                    color: _secondaryOrange.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          _buildGlassButton(
            onTap: () => _showShareOptions(),
            child: Icon(
              Icons.share,
              color: isDarkMode ? _darkText : Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? _darkCard
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Raporu Paylaş',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? _darkText
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                      Icons.share,
                      'Aileye\nGönder',
                      _primaryBlue,
                      _sharePdfReport,
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                _buildShareOption(
                      Icons.screenshot,
                      'Ekran\nGörüntüsü',
                      _successGreen,
                      _takeScreenshot,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? _darkText
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BEKLEME İÇERİĞİ (Sonuçlar Açıklanmadan Önce)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWaitingContent(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kilit / Kum saati animasyonu
            _buildGlassContainer(
                  padding: const EdgeInsets.all(32),
                  isDarkMode: isDarkMode,
                  child: Column(
                    children: [
                      // Animasyonlu ikon
                      TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 6.28 * 0.1,
                                child: Icon(
                                  Icons.hourglass_top,
                                  size: 100,
                                  color: _secondaryOrange.withOpacity(0.8),
                                ),
                              );
                            },
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 3000.ms, begin: 0, end: 0.05)
                          .then()
                          .rotate(duration: 3000.ms, begin: 0.05, end: 0),

                      const SizedBox(height: 24),

                      // Başlık
                      Text(
                        '🔮 Büyük An Geliyor!',
                        style: TextStyle(
                          color: _secondaryOrange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sonuçlar Pazar 20:00\'da açıklanacak',
                        style: TextStyle(
                          color: isDarkMode
                              ? _darkText.withOpacity(0.7)
                              : Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // Geri sayım
            _buildCountdownTimer(isDarkMode)
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2),

            // Kullanıcının cevap özeti (varsa)
            if (widget.result != null) ...[
              const SizedBox(height: 32),
              _buildAnswerSummary(isDarkMode)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(bool isDarkMode) {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      borderColor: _secondaryOrange.withOpacity(0.3),
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: _secondaryOrange, size: 24),
              const SizedBox(width: 12),
              Text(
                _formatDuration(_remainingTime),
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sonuçlara kalan süre',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.6)
                  : Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSummary(bool isDarkMode) {
    return Column(
      children: [
        Text(
          'Senin Cevapların',
          style: TextStyle(
            color: isDarkMode
                ? _darkText.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniStatCard(
              'Doğru',
              widget.result?.dogru?.toString() ?? '-',
              _successGreen,
              isDarkMode,
            ),
            const SizedBox(width: 12),
            _buildMiniStatCard(
              'Yanlış',
              widget.result?.yanlis?.toString() ?? '-',
              _errorRed,
              isDarkMode,
            ),
            const SizedBox(width: 12),
            _buildMiniStatCard(
              'Boş',
              widget.result?.bos?.toString() ?? '-',
              _neutralGray,
              isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.6)
                  : Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SONUÇ İÇERİĞİ (Sonuçlar Açıklandıktan Sonra)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildResultsContent(bool isDarkMode) {
    if (widget.result == null) {
      return _buildNoParticipationContent(isDarkMode);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: RepaintBoundary(
        key: _reportKey,
        child: Column(
          children: [
            // ═══ BİLGİLENDİRİCİ KART ═══
            _buildInfoCard(
              isDarkMode,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // ═══ HERO AREA - Skor ve Sıralama ═══
            _buildHeroSection(
              isDarkMode,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

            const SizedBox(height: 24),

            // ═══ PERFORMANCE DASHBOARD - Ders Kartları ═══
            _buildPerformanceDashboard(isDarkMode)
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // ═══ ANALYTICS - Bar Chart ═══
            _buildAnalyticsChart(isDarkMode)
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // ═══ KNOWLEDGE MAP - Güçlü/Zayıf Yönler ═══
            _buildKnowledgeMap(isDarkMode)
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // ═══ GAMIFICATION - Rozetler ve Aksiyonlar ═══
            _buildGamificationSection(isDarkMode)
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // ═══ DETAYLI CEVAPLAR ═══
            _buildDetailedAnswers(isDarkMode)
                .animate()
                .fadeIn(delay: 1000.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoParticipationContent(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _buildGlassContainer(
          padding: const EdgeInsets.all(32),
          isDarkMode: isDarkMode,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: isDarkMode
                    ? _darkText.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Bu sınava katılmadın',
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Gelecek hafta seni bekliyoruz! 💪',
                style: TextStyle(
                  color: isDarkMode
                      ? _darkText.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📢 BİLGİLENDİRİCİ KART - Sıralama Tıklama İpucu
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryBlue.withOpacity(0.15),
            _secondaryOrange.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBlue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app, color: _primaryBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Sıralama detaylarını görmek için',
                  style: TextStyle(
                    color: isDarkMode ? _darkText : Colors.grey[800],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sıralama kartına dokun ve il, ilçe, Türkiye geneli sıralamalarını karşılaştır!',
                  style: TextStyle(
                    color: isDarkMode
                        ? _darkText.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 12,
                    height: 1.3,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isDarkMode ? _darkText.withOpacity(0.4) : Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1️⃣ HERO SECTION - Circular Progress + Sıralama Badge
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(bool isDarkMode) {
    final maxScore = 500.0; // 500 tam puan
    final currentScore = (widget.result?.puan ?? 0).toDouble();
    final siralama = widget.result?.siralama;
    final toplamKatilimci = widget.result?.toplamKatilimci;

    // Top % hesapla (yüksek puan = düşük top %)
    // Top %7 demek ilk %7'desin (iyi), Top %93 demek ilk %93'tesin (kötü)
    double topPercent = 100;
    if (siralama != null && toplamKatilimci != null && toplamKatilimci > 0) {
      topPercent = (siralama / toplamKatilimci * 100);
    }

    return Row(
      children: [
        // Sol: Skor Kartı
        Expanded(
          child: _buildScoreCardCompact(currentScore, maxScore, isDarkMode),
        ),

        const SizedBox(width: 16),

        // Sağ: Sıralama Kartı (tıklanabilir)
        Expanded(
          child: GestureDetector(
            onTap: () => _showRankingDetailModal(isDarkMode),
            child: _buildRankingCardCompact(
              siralama,
              toplamKatilimci,
              topPercent,
              isDarkMode,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏆 SIRALAMA DETAY MODAL - İl, İlçe, Türkiye Karşılaştırması
  // ─────────────────────────────────────────────────────────────────────────
  void _showRankingDetailModal(bool isDarkMode) {
    final result = widget.result;
    if (result == null) return;

    final turkiyeSiralama = result.siralama ?? 0;
    final turkiyeKatilimci = result.toplamKatilimci ?? 0;
    final ilSiralama = result.ilSiralama ?? 0;
    final ilKatilimci = result.ilToplamKatilimci ?? 0;
    final ilceSiralama = result.ilceSiralama ?? 0;
    final ilceKatilimci = result.ilceToplamKatilimci ?? 0;

    // Kullanıcı il/ilçe bilgisi - profil kurulumundan (dinamik)
    final userCity = _userCity.isNotEmpty
        ? _userCity
        : (result.userCity ?? 'Bilinmiyor');
    final userDistrict = _userDistrict.isNotEmpty
        ? _userDistrict
        : (result.userDistrict ?? 'Bilinmiyor');

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDarkMode ? _darkBg : const Color(0xFF1A237E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Başlık
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard, color: _goldBadge, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Sıralama Detayları',
                    style: TextStyle(
                      color: isDarkMode ? _darkText : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable içerik
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // İlçe Sıralaması
                    _buildRankingDetailCard(
                      icon: Icons.location_city,
                      title: userDistrict,
                      subtitle: 'İlçe Sıralaması',
                      rank: ilceSiralama,
                      total: ilceKatilimci,
                      color: _successGreen,
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 12),

                    // İl Sıralaması
                    _buildRankingDetailCard(
                      icon: Icons.map,
                      title: userCity,
                      subtitle: 'İl Sıralaması',
                      rank: ilSiralama,
                      total: ilKatilimci,
                      color: _primaryBlue,
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 12),

                    // Türkiye Sıralaması
                    _buildRankingDetailCard(
                      icon: Icons.public,
                      title: 'Türkiye Geneli',
                      subtitle: 'Ulusal Sıralama',
                      rank: turkiyeSiralama,
                      total: turkiyeKatilimci,
                      color: _goldBadge,
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 24),

                    // Karşılaştırma Grafiği
                    _buildRankingComparisonChart(
                      ilceSiralama: ilceSiralama,
                      ilceKatilimci: ilceKatilimci,
                      ilSiralama: ilSiralama,
                      ilKatilimci: ilKatilimci,
                      turkiyeSiralama: turkiyeSiralama,
                      turkiyeKatilimci: turkiyeKatilimci,
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int rank,
    required int total,
    required Color color,
    required bool isDarkMode,
  }) {
    // Top % hesapla (yüksek puan = düşük top %)
    // Top %7 demek ilk %7'desin (iyi), Top %93 demek ilk %93'tesin (kötü)
    final topPercent = total > 0 ? (rank / total * 100) : 100.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title: $rank / $total (Top ${_formatDecimal(topPercent)}%)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? _darkCard : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // İkon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(width: 16),

            // Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode ? _darkText : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDarkMode
                          ? _darkText.withOpacity(0.6)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Sıralama
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$rank',
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      TextSpan(
                        text: '/$total',
                        style: TextStyle(
                          color: isDarkMode
                              ? _darkText.withOpacity(0.5)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Top ${_formatDecimal(topPercent)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingComparisonChart({
    required int ilceSiralama,
    required int ilceKatilimci,
    required int ilSiralama,
    required int ilKatilimci,
    required int turkiyeSiralama,
    required int turkiyeKatilimci,
    required bool isDarkMode,
  }) {
    // Grafik doluluk yüzdesi hesapla (Yüksek = daha iyi = daha dolu grafik)
    // Top %7 demek 100 - 7 = %93 başarılı demek → grafik %93 dolu olmalı
    final ilceFillPercent = ilceKatilimci > 0
        ? ((ilceKatilimci - ilceSiralama) / ilceKatilimci * 100)
        : 0.0;
    final ilFillPercent = ilKatilimci > 0
        ? ((ilKatilimci - ilSiralama) / ilKatilimci * 100)
        : 0.0;
    final turkiyeFillPercent = turkiyeKatilimci > 0
        ? ((turkiyeKatilimci - turkiyeSiralama) / turkiyeKatilimci * 100)
        : 0.0;

    // Display yüzdesi (Top %X olarak gösterilecek gerçek yüzde)
    final ilceDisplayPercent = ilceKatilimci > 0
        ? (ilceSiralama / ilceKatilimci * 100)
        : 0.0;
    final ilDisplayPercent = ilKatilimci > 0
        ? (ilSiralama / ilKatilimci * 100)
        : 0.0;
    final turkiyeDisplayPercent = turkiyeKatilimci > 0
        ? (turkiyeSiralama / turkiyeKatilimci * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? _darkCard : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Sıralama Karşılaştırması',
            style: TextStyle(
              color: isDarkMode ? _darkText : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // İlçe bar
          _buildComparisonBar(
            label: 'İlçe',
            fillPercentage: ilceFillPercent,
            displayPercentage: ilceDisplayPercent,
            color: _successGreen,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),

          // İl bar
          _buildComparisonBar(
            label: 'İl',
            fillPercentage: ilFillPercent,
            displayPercentage: ilDisplayPercent,
            color: _primaryBlue,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),

          // Türkiye bar
          _buildComparisonBar(
            label: 'Türkiye',
            fillPercentage: turkiyeFillPercent,
            displayPercentage: turkiyeDisplayPercent,
            color: _goldBadge,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 8),
          Text(
            '* Dolu grafik = Daha iyi sıralama',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.4)
                  : Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required double fillPercentage,
    required double displayPercentage,
    required Color color,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: isDarkMode ? _darkText : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Arka plan
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Dolgu (yüksek başarı = daha dolu = daha iyi)
              FractionallySizedBox(
                widthFactor: (fillPercentage / 100).clamp(0.05, 1.0),
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 65,
          child: Text(
            'Top ${_formatDecimal(displayPercentage)}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Kompakt Skor Kartı (sol taraf)
  Widget _buildScoreCardCompact(
    double currentScore,
    double maxScore,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkCard, _darkCard.withOpacity(0.8)]
              : [_primaryBlue.withOpacity(0.2), _primaryBlue.withOpacity(0.1)],
        ),
        border: Border.all(color: _primaryBlue.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: _primaryBlue, size: 32),
          ),

          const SizedBox(height: 12),

          // Puan başlığı
          Text(
            'Puanın',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 4),

          // Animasyonlu puan
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Text(
                _formatDecimal(_scoreAnimation.value),
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  height: 1,
                ),
              );
            },
          ),

          const SizedBox(height: 2),

          // Max puan
          Text(
            '/ ${maxScore.toInt()}',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.5)
                  : Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 12),

          // Başarı mesajı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreGradientColor(
                currentScore / maxScore,
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getScoreMessage(widget.result?.puan ?? 0),
              style: TextStyle(
                color: _getScoreGradientColor(currentScore / maxScore),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Kompakt Sıralama Kartı (sağ taraf)
  Widget _buildRankingCardCompact(
    int? siralama,
    int? toplamKatilimci,
    double percentile,
    bool isDarkMode,
  ) {
    if (siralama == null || toplamKatilimci == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [_darkCard, _darkCard.withOpacity(0.8)]
                : [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[700]!
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty,
                color: isDarkMode
                    ? _darkText.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Sıralama\nhesaplanıyor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode
                      ? _darkText.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkCard, _darkCard.withOpacity(0.8)]
              : [_goldBadge.withOpacity(0.2), _goldBadge.withOpacity(0.1)],
        ),
        border: Border.all(color: _goldBadge.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _goldBadge.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trophy İkon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _goldBadge.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getRankIcon(siralama, toplamKatilimci),
              color: _goldBadge,
              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          // Sıralama başlığı
          Text(
            '🇹🇷 Sıralaman',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 4),

          // Sıralama numarası
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$siralama',
                  style: TextStyle(
                    color: isDarkMode ? _darkText : Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(
                    color: isDarkMode ? _darkText : Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Toplam katılımcı
          Text(
            '$toplamKatilimci kişi arasında',
            style: TextStyle(
              color: isDarkMode
                  ? _darkText.withOpacity(0.5)
                  : Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 12),

          // Percentile badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Top ${_formatDecimal(percentile)}%',
              style: TextStyle(
                color: _successGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Eski _buildHeroSection içeriğinden gereken yardımcı metodlar
  Color _getScoreGradientColor(double ratio) {
    if (ratio >= 0.8) return _successGreen;
    if (ratio >= 0.6) return _primaryBlue;
    if (ratio >= 0.4) return _secondaryOrange;
    return _errorRed;
  }

  IconData _getRankIcon(int rank, int total) {
    final percentage = rank / total * 100;
    if (percentage <= 1) return Icons.emoji_events;
    if (percentage <= 10) return Icons.military_tech;
    if (percentage <= 25) return Icons.star;
    return Icons.trending_up;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2️⃣ PERFORMANCE DASHBOARD - Ders Kartları Grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPerformanceDashboard(bool isDarkMode) {
    final performances = _subjectPerformances;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '📊 Ders Bazlı Performans',
            style: TextStyle(
              color: isDarkMode ? _darkText : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: performances.length,
          itemBuilder: (context, index) {
            final perf = performances[index];
            return _buildSubjectCard(perf, isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(SubjectPerformance perf, bool isDarkMode) {
    final total = perf.totalQuestions;
    final net = perf.correct - (perf.wrong * 0.25);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkCard, _darkCard.withOpacity(0.7)]
              : [perf.color.withOpacity(0.2), perf.color.withOpacity(0.1)],
        ),
        border: Border.all(color: perf.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: perf.color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım - İkon ve Ders Adı
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: perf.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(perf.icon, color: perf.color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  perf.name,
                  style: TextStyle(
                    color: isDarkMode ? _darkText : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Mini D/Y/B Bar
          Row(
            children: [
              _buildMiniBar(perf.correct, _successGreen, total),
              const SizedBox(width: 2),
              _buildMiniBar(perf.wrong, _errorRed, total),
              const SizedBox(width: 2),
              _buildMiniBar(perf.empty, _neutralGray, total),
            ],
          ),

          const SizedBox(height: 8),

          // D/Y/B Sayıları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('D', perf.correct.toString(), _successGreen),
              _buildMiniStat('Y', perf.wrong.toString(), _errorRed),
              _buildMiniStat('B', perf.empty.toString(), _neutralGray),
            ],
          ),

          const SizedBox(height: 8),

          // Net Puan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net:',
                style: TextStyle(
                  color: isDarkMode
                      ? _darkText.withOpacity(0.6)
                      : Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                net.toStringAsFixed(2),
                style: TextStyle(
                  color: perf.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(int value, Color color, int total) {
    final ratio = total > 0 ? value / total : 0.0;
    return Expanded(
      flex: math.max(1, (ratio * 100).toInt()),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label:$value',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3️⃣ ANALYTICS CHART - Türkiye Karşılaştırması
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAnalyticsChart(bool isDarkMode) {
    final performances = _subjectPerformances;

    // Türkiye ortalamasını JSON'dan al (ders adına göre), yoksa varsayılan
    // Not: turkeyAverages artık doğru sayısını temsil ediyor
    final turkeyAverages = performances.map((p) {
      if (widget.exam.turkeyAverages != null &&
          widget.exam.turkeyAverages!.containsKey(p.name)) {
        return widget.exam.turkeyAverages![p.name]!;
      }
      // Varsayılan: kullanıcının doğru sayısının %70'i
      return p.correct * 0.7;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkCard, _darkCard.withOpacity(0.8)]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: _primaryBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Sen vs Türkiye Ortalaması',
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Legend
          Row(
            children: [
              _buildLegendItem('Sen', _primaryBlue),
              const SizedBox(width: 16),
              _buildLegendItem('Türkiye Ort.', _neutralGray.withOpacity(0.5)),
            ],
          ),

          const SizedBox(height: 20),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(performances, turkeyAverages),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDarkMode ? _darkCard : Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final perf = performances[groupIndex];
                      final userCorrect = perf.correct;
                      final turkeyCorrect = turkeyAverages[groupIndex];

                      // rodIndex 0 = kullanıcı, rodIndex 1 = Türkiye ortalaması
                      if (rodIndex == 0) {
                        return BarTooltipItem(
                          '${perf.name}\nSenin Doğrun: $userCorrect',
                          TextStyle(
                            color: isDarkMode ? _darkText : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      } else {
                        return BarTooltipItem(
                          '${perf.name}\nTürkiye Ort: ${turkeyCorrect.toStringAsFixed(1)}',
                          TextStyle(
                            color: isDarkMode ? _darkText : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      }
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= performances.length) {
                          return const SizedBox();
                        }
                        final perf = performances[value.toInt()];
                        // Ders adını kısalt
                        String shortName = _getShortLessonName(perf.name);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(perf.icon, color: perf.color, size: 14),
                              const SizedBox(height: 2),
                              Text(
                                shortName,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? _darkText.withOpacity(0.7)
                                      : Colors.white.withOpacity(0.7),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                      reservedSize: 48,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Doğru Sayısı',
                      style: TextStyle(
                        color: isDarkMode
                            ? _darkText.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    axisNameSize: 16,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDarkMode
                                ? _darkText.withOpacity(0.5)
                                : Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode
                        ? Colors.grey[800]!
                        : Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(performances.length, (index) {
                  final perf = performances[index];
                  final userCorrect = perf.correct.toDouble();
                  final turkeyCorrect = turkeyAverages[index];

                  // Responsive bar genişliği
                  final barWidth = performances.length > 4 ? 12.0 : 16.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: userCorrect,
                        color: _primaryBlue,
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: turkeyCorrect,
                        color: _neutralGray.withOpacity(0.4),
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(
    List<SubjectPerformance> performances,
    List<double> turkeyAverages,
  ) {
    double maxCorrect = 0;
    for (int i = 0; i < performances.length; i++) {
      final p = performances[i];
      final userCorrect = p.correct.toDouble();
      final turkeyCorrect = i < turkeyAverages.length ? turkeyAverages[i] : 0.0;
      if (userCorrect > maxCorrect) maxCorrect = userCorrect;
      if (turkeyCorrect > maxCorrect) maxCorrect = turkeyCorrect;
    }
    // Minimum 10, maksimum değer + 2 (grafik daha iyi görünsün)
    return math.max(10.0, (maxCorrect + 2).ceilToDouble());
  }

  /// Ders adını kısalt (grafik için)
  String _getShortLessonName(String name) {
    final shortNames = {
      'Matematik': 'Mat',
      'Türkçe': 'Tür',
      'Fen Bilgisi': 'Fen',
      'Fen Bilimleri': 'Fen',
      'Sosyal Bilgiler': 'Sos',
      'Hayat Bilgisi': 'Hayat',
      'İngilizce': 'İng',
      'T.C İnkılap Tarihi': 'İnk',
      'Din Kültürü': 'Din',
    };
    return shortNames[name] ?? name.substring(0, math.min(3, name.length));
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter'),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4️⃣ KNOWLEDGE MAP - Güçlü ve Zayıf Yönler
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildKnowledgeMap(bool isDarkMode) {
    // ÖNEMLI: Bu metod sadece sınavda gerçekten var olan soruların konularını gösterir.
    // _topicNames SQLite veritabanından yüklenir ve tüm sınıfların (3-8) konularını içerir.
    // Sınavda olmayan konular hiçbir zaman gösterilmez.

    // Konu ID'lerini insan okunabilir isimlere çevir
    String getTopicDisplayName(String topicId) {
      // _topicNames state'inden al, yoksa topicId'yi döndür
      return _topicNames[topicId] ?? topicId;
    }

    // Ders bazlı gruplandırma için Map
    final lessonTopics = <String, List<TopicPerformance>>{};

    for (int i = 0; i < widget.exam.questions.length; i++) {
      final question = widget.exam.questions[i];

      // Sadece topicId'si olan soruları işle (null veya GENEL olanları atla)
      final topicId = question.topicId;
      if (topicId == null || topicId.isEmpty || topicId == 'GENEL') {
        continue;
      }

      final lessonName = question.lessonName ?? 'Genel';
      final topicDisplayName = getTopicDisplayName(topicId);
      final questionId = (i + 1).toString();
      final userAnswer = widget.result?.cevaplar[questionId];
      final isCorrect = userAnswer == question.correctAnswer;

      // Ders grubunu oluştur
      if (!lessonTopics.containsKey(lessonName)) {
        lessonTopics[lessonName] = [];
      }

      // Bu topic zaten var mı?
      final existingTopic = lessonTopics[lessonName]!.firstWhere(
        (t) => t.name == topicDisplayName,
        orElse: () => TopicPerformance(
          name: topicDisplayName,
          topicId: topicId,
          lessonName: lessonName,
          correct: 0,
          total: 0,
        ),
      );

      final updatedTopic = TopicPerformance(
        name: topicDisplayName,
        topicId: topicId,
        lessonName: lessonName,
        correct: existingTopic.correct + (isCorrect ? 1 : 0),
        total: existingTopic.total + 1,
      );

      // Eski topic'i sil, yenisini ekle
      lessonTopics[lessonName]!.removeWhere((t) => t.name == topicDisplayName);
      lessonTopics[lessonName]!.add(updatedTopic);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [_darkCard, _darkCard.withOpacity(0.8)]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: _secondaryOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Güçlü ve Zayıf Yönlerin',
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Her ders için ayrı bölüm
          ...lessonTopics.entries.map((entry) {
            final lessonName = entry.key;
            final topics = entry.value;
            final strengths = topics.where((t) => t.successRate >= 80).toList();
            final weaknesses = topics.where((t) => t.successRate < 80).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ders başlığı
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(lessonName).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getSubjectIcon(lessonName),
                        color: _getSubjectColor(lessonName),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lessonName,
                        style: TextStyle(
                          color: isDarkMode ? _darkText : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Güçlü yönler
                if (strengths.isNotEmpty) ...[
                  _buildTopicSectionHeader(
                    '💪 Güçlü',
                    _successGreen,
                    isDarkMode,
                  ),
                  const SizedBox(height: 8),
                  ...strengths.map((t) => _buildTopicItem(t, true, isDarkMode)),
                  const SizedBox(height: 12),
                ],

                // Zayıf yönler
                if (weaknesses.isNotEmpty) ...[
                  _buildTopicSectionHeader(
                    '⚠️ Geliştir',
                    _warningOrange,
                    isDarkMode,
                  ),
                  const SizedBox(height: 8),
                  ...weaknesses.map(
                    (t) => _buildTopicItem(t, false, isDarkMode),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            );
          }),

          if (lessonTopics.isEmpty)
            Center(
              child: Text(
                'Konu bilgisi bulunamadı',
                style: TextStyle(
                  color: isDarkMode
                      ? _darkText.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicSectionHeader(String title, Color color, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildTopicItem(
    TopicPerformance topic,
    bool isStrength,
    bool isDarkMode,
  ) {
    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (isStrength ? _successGreen : _warningOrange).withOpacity(
              0.1,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isStrength ? _successGreen : _warningOrange).withOpacity(
                0.3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isStrength ? Icons.check_circle : Icons.warning_amber,
                color: isStrength ? _successGreen : _warningOrange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: topic.name,
                      child: Text(
                        topic.name,
                        style: TextStyle(
                          color: isDarkMode ? _darkText : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${topic.correct}/${topic.total} doğru (${_formatDecimal(topic.successRate)}%)',
                      style: TextStyle(
                        color: isDarkMode
                            ? _darkText.withOpacity(0.6)
                            : Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isStrength)
                TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        // Test listesi ekranına yönlendir
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestListScreen(
                              topicId: topic.topicId,
                              topicName: topic.name,
                              lessonName: topic.lessonName,
                              color: _warningOrange,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _warningOrange.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.replay,
                            color: _warningOrange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Tekrar Et',
                            style: TextStyle(
                              color: _warningOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      duration: 1500.ms,
                      color: _warningOrange.withOpacity(0.3),
                    ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isStrength ? -0.1 : 0.1, end: 0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5️⃣ GAMIFICATION SECTION - Rozetler ve Aksiyonlar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGamificationSection(bool isDarkMode) {
    // Rozet hesaplama
    final badges = _calculateBadges();

    return Column(
      children: [
        // Rozetler
        if (badges.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [_darkCard, _darkCard.withOpacity(0.8)]
                    : [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
              ),
              border: Border.all(
                color: isDarkMode
                    ? Colors.grey[700]!
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: _goldBadge, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Kazandığın Rozetler',
                      style: TextStyle(
                        color: isDarkMode ? _darkText : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges
                      .map((badge) => _buildBadgeChip(badge, isDarkMode))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Aksiyon Butonları
        _buildActionButtons(isDarkMode),
      ],
    );
  }

  List<BadgeInfo> _calculateBadges() {
    final badges = <BadgeInfo>[];
    final result = widget.result;
    if (result == null) return badges;

    final maxScore = widget.exam.questions.length * 25;
    final scorePercent = (result.puan ?? 0) / maxScore * 100;
    final siralama = result.siralama;
    final total = result.toplamKatilimci ?? 1;

    // Skor bazlı rozetler
    if (scorePercent >= 90) {
      badges.add(BadgeInfo('Mükemmeliyetçi', Icons.star, _goldBadge));
    } else if (scorePercent >= 80) {
      badges.add(BadgeInfo('Başarılı', Icons.thumb_up, _silverBadge));
    }

    // Sıralama bazlı rozetler
    if (siralama != null) {
      final rankPercent = siralama / total * 100;
      if (rankPercent <= 1) {
        badges.add(BadgeInfo('Türkiye 1. si', Icons.emoji_events, _goldBadge));
      } else if (rankPercent <= 5) {
        badges.add(BadgeInfo('Top 5%', Icons.military_tech, _goldBadge));
      } else if (rankPercent <= 10) {
        badges.add(BadgeInfo('Top 10%', Icons.workspace_premium, _silverBadge));
      }
    }

    // Ders bazlı rozetler
    for (final perf in _subjectPerformances) {
      if (perf.totalQuestions > 0 && perf.correct == perf.totalQuestions) {
        badges.add(BadgeInfo('${perf.name} Ustası', perf.icon, perf.color));
      }
    }

    // Hiç yanlış yoksa
    if ((result.yanlis ?? 0) == 0 && (result.dogru ?? 0) > 0) {
      badges.add(BadgeInfo('Hatasız Kahraman', Icons.verified, _successGreen));
    }

    return badges;
  }

  Widget _buildBadgeChip(BadgeInfo badge, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [badge.color.withOpacity(0.3), badge.color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badge.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, color: badge.color, size: 18),
          const SizedBox(width: 6),
          Text(
            badge.name,
            style: TextStyle(
              color: isDarkMode ? _darkText : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Column(
      children: [
        // Ana Aksiyon - Düello Butonu
        GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DuelGameSelectionScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _secondaryOrange,
                      _secondaryOrange.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _secondaryOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_mma, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Düelloya Katıl ve Seviye Atla!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),

        const SizedBox(height: 12),

        // İkincil Aksiyonlar
        _buildSecondaryAction(
              Icons.share,
              'Raporu Paylaş',
              _primaryBlue,
              isDarkMode,
              () => _showShareOptions(),
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildSecondaryAction(
    IconData icon,
    String label,
    Color color,
    bool isDarkMode,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DETAYLI CEVAPLAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetailedAnswers(bool isDarkMode) {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(20),
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: _secondaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cevap Anahtarı',
                style: TextStyle(
                  color: isDarkMode ? _darkText : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...widget.exam.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final questionId = (index + 1).toString();
            final userAnswer = widget.result?.cevaplar[questionId];
            final isCorrect = userAnswer == question.correctAnswer;
            final isEmpty = userAnswer == null || userAnswer == 'EMPTY';

            return _buildAnswerRow(
              questionId: questionId,
              userAnswer: isEmpty ? '-' : userAnswer,
              correctAnswer: question.correctAnswer,
              isCorrect: isCorrect,
              isEmpty: isEmpty,
              isDarkMode: isDarkMode,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnswerRow({
    required String questionId,
    required String userAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required bool isEmpty,
    required bool isDarkMode,
  }) {
    final bgColor = isEmpty
        ? (isDarkMode
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.white.withOpacity(0.05))
        : isCorrect
        ? _successGreen.withOpacity(0.15)
        : _errorRed.withOpacity(0.15);

    final iconColor = isEmpty
        ? _neutralGray
        : (isCorrect ? _successGreen : _errorRed);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Soru numarası
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                questionId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Senin cevabın
          Expanded(
            child: Row(
              children: [
                Text(
                  'Sen: ',
                  style: TextStyle(
                    color: isDarkMode
                        ? _darkText.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                Text(
                  userAnswer,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Doğru cevap
          Row(
            children: [
              Text(
                'Doğru: ',
                style: TextStyle(
                  color: isDarkMode
                      ? _darkText.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              Text(
                correctAnswer,
                style: TextStyle(
                  color: _successGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // İkon
          Icon(
            isEmpty
                ? Icons.remove_circle_outline
                : isCorrect
                ? Icons.check_circle
                : Icons.cancel,
            color: iconColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI WIDGET'LAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color? borderColor,
    bool isDarkMode = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  borderColor ??
                  (isDarkMode
                      ? Colors.grey[700]!
                      : Colors.white.withOpacity(0.2)),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [_darkCard, _darkCard.withOpacity(0.7)]
                  : [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI METODLAR (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  // ignore: unused_element - Gelecekte kullanılacak
  Color _getScoreColor(int score) {
    // Toplam max puan 500
    final percentage = score / 500 * 100;

    if (percentage >= 80) return _successGreen;
    if (percentage >= 60) return _primaryBlue;
    if (percentage >= 40) return _secondaryOrange;
    return _errorRed;
  }

  String _getScoreMessage(int score) {
    // Toplam max puan 500
    final percentage = score / 500 * 100;

    // Her yüzdelik aralığa özel samimi, komik ve içten mesajlar
    if (percentage >= 95) return 'Efsane oldun! Sen bir dahisin! 🏆✨';
    if (percentage >= 90) return 'Yıldız gibi parlıyorsun! 🌟💫';
    if (percentage >= 85) return 'Süpersin! Annene göster bunu! 🦸‍♂️';
    if (percentage >= 80) return 'Harikasın! Böyle devam et! 🎉';
    if (percentage >= 75) return 'Çok iyisin! Gurur duyuyoruz! 🎊';
    if (percentage >= 70) return 'Helal sana! Muhteşemsin! 👏';
    if (percentage >= 65) return 'Aferin! Bu tempo sürsün! 💪';
    if (percentage >= 60) return 'İyi gidiyorsun! Yükselişteyiz! 🚀';
    if (percentage >= 55) return 'Fena değil! Potansiyelin var! 😊';
    if (percentage >= 50) return 'Ortalama üstü! Biraz daha gayret! 🎯';
    if (percentage >= 45) return 'Az kaldı! Hedefe yaklaşıyorsun! 🏃';
    if (percentage >= 40) return 'Gelişiyorsun! Pes etme! 💪';
    if (percentage >= 35) return 'Yolun başındasın! Çalışırsan olur! 📚';
    if (percentage >= 30) return 'Daha çok çalışman lazım! 📖';
    if (percentage >= 25) return 'Biraz daha emek ver! Sen yaparsın! 💡';
    if (percentage >= 20) return 'Konuları tekrar et! Olacak! 🔄';
    return 'Hiç sorun değil! Yeniden dene! 🌱';
  }

  // ignore: unused_element - Gelecekte kullanılacak
  String _getRankingMessage(int rank, int total) {
    final percentage = (rank / total * 100);
    if (percentage <= 1) return 'İlk %1\'desin! Süpersin! 🏆';
    if (percentage <= 5) return 'İlk %5\'tesin! Harika! 🥇';
    if (percentage <= 10) return 'İlk %10\'dasın! Çok iyi! 🥈';
    if (percentage <= 25) return 'İlk %25\'tesin! Başarılı! 🥉';
    if (percentage <= 50) return 'Üst yarıdasın! İyi gidiyorsun! 👍';
    return 'Gelişmeye devam et! 💪';
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
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 HELPER DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Ders bazlı performans bilgisi
class SubjectPerformance {
  final String name;
  final IconData icon;
  final Color color;
  final int correct;
  final int wrong;
  final int empty;
  final int totalQuestions;

  const SubjectPerformance({
    required this.name,
    required this.icon,
    required this.color,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.totalQuestions,
  });

  double get successRate =>
      totalQuestions > 0 ? (correct / totalQuestions * 100) : 0;
  double get net => correct - (wrong * 0.25);
}

/// Konu bazlı performans bilgisi
class TopicPerformance {
  final String name;
  final String topicId;
  final String lessonName;
  final int correct;
  final int total;

  const TopicPerformance({
    required this.name,
    required this.topicId,
    required this.lessonName,
    required this.correct,
    required this.total,
  });

  double get successRate => total > 0 ? (correct / total * 100) : 0;
}

/// Rozet bilgisi
class BadgeInfo {
  final String name;
  final IconData icon;
  final Color color;

  const BadgeInfo(this.name, this.icon, this.color);
}
