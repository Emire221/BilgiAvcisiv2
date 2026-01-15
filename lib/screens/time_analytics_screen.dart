import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';
import '../services/time_tracking_service.dart';

/// Haftalık Eğitim Süresi Grafiği Ekranı
class TimeAnalyticsScreen extends StatefulWidget {
  const TimeAnalyticsScreen({super.key});

  @override
  State<TimeAnalyticsScreen> createState() => _TimeAnalyticsScreenState();
}

class _TimeAnalyticsScreenState extends State<TimeAnalyticsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _weekData = [];
  bool _isLoading = true;
  late AnimationController _animController;
  StreamSubscription<int>? _timeSubscription;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadData();
    _subscribeToTimeStream();
  }

  @override
  void dispose() {
    _timeSubscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper().getWeeklyTimeData();
    setState(() {
      _weekData = data;
      _isLoading = false;
    });
    _animController.forward();
    // Veri yüklendikten sonra anlık veriyi de kontrol et (ilk açılışta güncel olsun)
    if (mounted) {
      _updateTodayData(TimeTrackingService().todaySeconds);
    }
  }

  void _subscribeToTimeStream() {
    _timeSubscription = TimeTrackingService().timeStream.listen((totalSeconds) {
      if (mounted) {
        _updateTodayData(totalSeconds);
      }
    });
  }

  void _updateTodayData(int totalSeconds) {
    if (_weekData.isEmpty) return;

    final now = DateTime.now();
    // Pazartesi=1 ... Pazar=7. Listemiz 0..6 arası indeksli.
    // _weekData genellikle 7 günlük veri içerir ve indeksler günlere karşılık gelir.
    // DatabaseHelper'dan gelen verinin formatına güveniyoruz (Pzt=0, Sal=1...).
    final todayIndex = now.weekday - 1;

    if (todayIndex >= 0 && todayIndex < _weekData.length) {
      final currentMinutesInList = _weekData[todayIndex]['durationMinutes'] as int;
      final liveMinutes = (totalSeconds / 60).floor(); // Aşağı yuvarla veya round

      // Sadece dakika değiştiyse güncelle (gereksiz build'i önlemek için)
      // Ancak animasyonun akıcı olması için her saniye güncellemek de bir seçenek,
      // ama bar chart dakika bazlı olduğu için gerek yok.
      // EĞER mevcut veri veritabanından geldiyse ve eski olabilirse,
      // liveMinutes daha büyük veya eşitse güncelle.
      if (liveMinutes != currentMinutesInList) {
        setState(() {
          // Map'i güncellemek için yeni bir map oluşturup değiştirmeliyiz (immutable ilkesi)
          final updatedDay = Map<String, dynamic>.from(_weekData[todayIndex]);
          updatedDay['durationMinutes'] = liveMinutes;
          _weekData[todayIndex] = updatedDay;
        });
      }
    }
  }

  int get _totalWeekMinutes =>
      _weekData.fold(0, (sum, d) => sum + (d['durationMinutes'] as int));

  int get _maxMinutes {
    if (_weekData.isEmpty) return 60;
    final max = _weekData
        .map((d) => d['durationMinutes'] as int)
        .reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 60;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Eğitimin İçin Ayırdığın Süre',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF0D0D1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                    const Color(0xFFF093FB),
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildContent(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(isDarkMode)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          Expanded(
            flex: 5,
            child: _buildChartCard(isDarkMode)
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
          ),
          const SizedBox(height: 12),
          _buildMotivationalCard(isDarkMode)
              .animate()
              .fadeIn(duration: 700.ms, delay: 400.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 14),
          // İlk gün kontrolü - dün verisi yoksa farklı göster
          _buildComparisonSection(isDarkMode),
        ],
      ),
    );
  }

  /// İlk gün mü kontrol et (Pazartesi veya ilk kullanım)
  bool get _isFirstDay {
    final now = DateTime.now();
    if (now.weekday == 1) return true; // Pazartesi
    
    // Dün verisi var mı kontrol et
    final yesterdayIndex = now.weekday - 2;
    if (yesterdayIndex < 0 || yesterdayIndex >= _weekData.length) return true;
    return false;
  }

  Widget _buildComparisonSection(bool isDarkMode) {
    if (_isFirstDay) {
      // İlk gün - yarın gel mesajı
      return _buildFirstDayCard(isDarkMode)
          .animate()
          .fadeIn(duration: 800.ms, delay: 600.ms)
          .slideY(begin: 0.3, end: 0);
    }

    // Normal durum - düne karşılaştırma
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Düne Karşı Savaş!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 750.ms, delay: 550.ms),
        _buildComparisonCard(isDarkMode)
            .animate()
            .fadeIn(duration: 800.ms, delay: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  /// İlk gün kartı - yarın gel mesajı
  Widget _buildFirstDayCard(bool isDarkMode) {
    final messages = [
      '🌟 Bugün ilk günün! Yarın gel, düne göre ne kadar ilerlediğini görelim!',
      '🚀 Harika bir başlangıç! Yarın "Düne Karşı Savaş" kilidi açılacak!',
      '🎯 İlk adımı attın! Yarın performansını karşılaştıracağız!',
      '💪 Süpersin! Yarın düne göre ne kadar geliştini göster!',
      '🔮 Geleceği görmek için yarına gel! Düne karşı savaş başlasın!',
    ];
    final message = messages[DateTime.now().hour % messages.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const FaIcon(FontAwesomeIcons.hourglassStart, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(bool isDarkMode) {
    int todayMinutes = 0;
    int yesterdayMinutes = 0;

    if (_weekData.length >= 2) {
      final now = DateTime.now();
      final todayIndex = now.weekday - 1;
      
      if (todayIndex >= 0 && todayIndex < _weekData.length) {
        todayMinutes = _weekData[todayIndex]['durationMinutes'] as int;
      }
      if (todayIndex > 0) {
        yesterdayMinutes = _weekData[todayIndex - 1]['durationMinutes'] as int;
      }
    }

    final difference = todayMinutes - yesterdayMinutes;
    final isUp = difference > 0;
    final isEqual = difference == 0;

    String message;
    IconData icon;
    List<Color> gradientColors;

    if (isEqual && todayMinutes == 0) {
      final zeroMessages = [
        '😴 Düne göre henüz başlamadın! Hadi bir kaç dakika ayır!',
        '🛋️ Düne göre sıfır dakika... Kanepe çok mu rahat?',
        '🎬 Düne göre 0 dakika! Film izlemek de güzel ama hadi başla!',
      ];
      message = zeroMessages[DateTime.now().minute % zeroMessages.length];
      icon = FontAwesomeIcons.bedPulse;
      gradientColors = [Colors.grey, Colors.blueGrey];
    } else if (isEqual) {
      final equalMessages = [
        '⚖️ Düne göre aynı tempoda gidiyorsun! Biraz daha zorla!',
        '🎯 Düne göre fark yok! Rekor kırmak için biraz daha çabala!',
      ];
      message = equalMessages[DateTime.now().minute % equalMessages.length];
      icon = FontAwesomeIcons.scaleBalanced;
      gradientColors = [Colors.blue, Colors.cyan];
    } else if (isUp) {
      final diffText = '$difference dakika';
      final upMessages = [
        '🔥 Düne göre $diffText daha fazla çalıştın! Yanıyorsun!',
        '🚀 Düne göre $diffText artış! Roket gibi yükseliyorsun!',
        '💥 Düne göre $diffText fazla! Sen bir makinesin!',
        '⚡ Düne göre $diffText kazandın! Elektrik verdin!',
        '🏆 Düne göre $diffText daha iyi! Şampiyon gibisin!',
        '🎯 Düne göre $diffText artış! Hedefi vurdun!',
        '💪 Düne göre $diffText fazla! Kasların çatırdıyor!',
      ];
      message = upMessages[DateTime.now().minute % upMessages.length];
      icon = FontAwesomeIcons.arrowTrendUp;
      gradientColors = [const Color(0xFF11998E), const Color(0xFF38EF7D)];
    } else {
      final diffText = '${-difference} dakika';
      final downMessages = [
        '😅 Düne göre $diffText az çalıştın! Olsun, telafi edersin!',
        '🐢 Düne göre $diffText eksik... Kaplumbağa modu mu?',
        '🎮 Düne göre $diffText düştük! Oyun oynadın dimi?',
        '💤 Düne göre $diffText az! Biraz uyukladık galiba...',
        '🍕 Düne göre $diffText geride! Pizza molası mı?',
        '📺 Düne göre $diffText eksik! Dizi mi izledin?',
        '🌧️ Düne göre $diffText az! Bugün tembellik günü mü?',
      ];
      message = downMessages[DateTime.now().minute % downMessages.length];
      icon = FontAwesomeIcons.arrowTrendDown;
      gradientColors = [const Color(0xFFFF6B35), const Color(0xFFE74C3C)];
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradientColors[0].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(bool isDarkMode) {
    final hours = _totalWeekMinutes ~/ 60;
    final minutes = _totalWeekMinutes % 60;
    
    String timeText;
    if (hours > 0 && minutes > 0) {
      timeText = '$hours saat $minutes dakika';
    } else if (hours > 0) {
      timeText = '$hours saat';
    } else {
      timeText = '$_totalWeekMinutes dakika';
    }

    final messages = [
      '🎉 Harikasın! Bu hafta eğitimine $timeText ayırdın!',
      '🚀 Süpersin! $timeText boyunca beynini çalıştırdın!',
      '⭐ Muhteşem! $timeText öğrenmeye adadın!',
      '🏆 Şampiyon! Bu hafta $timeText eğitim yaptın!',
      '💪 Aferin! $timeText kendinle yarıştın!',
    ];
    
    final message = messages[DateTime.now().weekday % messages.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.2),
            const Color(0xFFFFD700).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const FaIcon(FontAwesomeIcons.medal, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Başarım',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.contains('Bu hafta') ? message : 'Bu hafta: $message',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998E).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const FaIcon(FontAwesomeIcons.chartLine, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu Hafta Toplam',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildTimeDisplay(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final hours = _totalWeekMinutes ~/ 60;
    final minutes = _totalWeekMinutes % 60;

    if (hours > 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$hours',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 4, right: 8),
            child: Text(
              'saat',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          if (minutes > 0) ...[
            Text(
              '$minutes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 5, left: 4),
              child: Text(
                'dakika',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$_totalWeekMinutes',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 5, left: 4),
          child: Text(
            'dakika',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.calendarWeek,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Bu Hafta',
                style: TextStyle(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _maxMinutes.toDouble() * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.white.withValues(alpha: 0.9),
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.round()} dk',
                            const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: (_maxMinutes / 4).ceilToDouble().clamp(1, 100),
                          getTitlesWidget: (value, meta) {
                            // Sadece tam sayı değerleri göster
                            if (value != value.roundToDouble()) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${value.toInt()} dk',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white54 : Colors.black45,
                                fontSize: 9,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= _weekData.length) {
                              return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _weekData[index]['dayName'] ?? '',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (_maxMinutes / 4).ceilToDouble().clamp(1, 100),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDarkMode 
                              ? Colors.white.withValues(alpha: 0.08) 
                              : Colors.black.withValues(alpha: 0.08),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _weekData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final minutes = entry.value['durationMinutes'] as int;
                      final animatedValue = minutes * _animController.value;

                      final now = DateTime.now();
                      final isToday = index == (now.weekday - 1);
                      final gradient = isToday
                          ? const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
                            )
                          : const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            );

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: animatedValue,
                            width: 24,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: gradient,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _maxMinutes.toDouble() * 1.2,
                              color: isDarkMode 
                                  ? Colors.white.withValues(alpha: 0.05) 
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  duration: Duration.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
