import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';

/// 📊 Gelişim Analitik Ekranı
/// Ders ve konu bazlı başarı grafikleri
class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() =>
      _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Seçili ders
  String? _selectedDersId;
  String? _selectedDersAdi;

  // Veriler
  List<Map<String, dynamic>> _dersler = [];
  Map<String, double> _dersBasariOranlari = {};
  List<Map<String, dynamic>> _konular = [];
  Map<String, double> _konuBasariOranlari = {};
  Map<String, bool> _konuCozulduMu = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Dersleri ve başarı oranlarını yükle
      await _loadDersBasariOranlari();

      // İlk dersi seçmek yerine kullanıcıya seçim hakkı bırakıyoruz

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDersBasariOranlari() async {
    final dersler = await _dbHelper.getLessonSuccessRates();

    final Map<String, double> oranlar = {};
    for (final ders in dersler) {
      final dersId = ders['dersID'] as String;
      final basari = (ders['basariOrani'] as num?)?.toDouble() ?? 0.0;
      oranlar[dersId] = basari;
    }

    setState(() {
      _dersler = dersler;
      _dersBasariOranlari = oranlar;
    });
  }

  Future<void> _selectDers(String dersId, String dersAdi) async {
    setState(() {
      _selectedDersId = dersId;
      _selectedDersAdi = dersAdi;
    });

    // Konu başarı oranlarını yükle
    final konular = await _dbHelper.getTopicSuccessRates(dersId);

    final Map<String, double> oranlar = {};
    final Map<String, bool> cozulduMu = {};

    for (final konu in konular) {
      final konuId = konu['konuID'] as String;
      final basari = (konu['basariOrani'] as num?)?.toDouble() ?? 0.0;
      final cozulenTest = (konu['cozulenTest'] as int?) ?? 0;
      oranlar[konuId] = basari;
      cozulduMu[konuId] = cozulenTest > 0;
    }

    setState(() {
      _konular = konular;
      _konuBasariOranlari = oranlar;
      _konuCozulduMu = cozulduMu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(isDarkMode),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _buildContent(isDarkMode),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.chartLine,
            color: Colors.cyan,
            size: 20,
          ),
          const SizedBox(width: 10),
          isDarkMode
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.cyan, Colors.blue, Colors.purple],
                  ).createShader(bounds),
                  child: const Text(
                    'Gelişim Grafiği',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : const Text(
                  'Gelişim Grafiği',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF0f0c29),
                  const Color(0xFF302b63),
                  const Color(0xFF24243e),
                ]
              : [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_dersler.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yönlendirici Bilgilendirme
          _buildInfoCard(isDarkMode),

          const SizedBox(height: 20),

          // Ders Karşılaştırma Grafiği
          _buildSectionTitle(
            '📚 Ders Başarı Karşılaştırması',
            'Derse tıklayarak detayları görün',
          ),
          const SizedBox(height: 12),
          _buildLessonChart(isDarkMode),

          // Rapor Butonu - her zaman göster
          const SizedBox(height: 24),
          _buildReportButton(isDarkMode),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.lightbulb,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nasıl Kullanılır?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grafikteki derse tıklayarak o dersin konu detaylarını görebilirsin. Düşük puanlı konulara odaklanmayı unutma! 💪',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonChart(bool isDarkMode) {
    // Grafik yüksekliğini ekran yüksekliğinin %35'i ile sınırla (min 220, max 350)
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = (screenHeight * 0.35).clamp(220.0, 350.0);

    return Container(
          height: chartHeight,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final ders = _dersler[group.x];
                    return BarTooltipItem(
                      '${ders['dersAdi']}\n%${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (response?.spot != null &&
                      event.isInterestedForInteractions) {
                    final index = response!.spot!.touchedBarGroupIndex;
                    if (index >= 0 && index < _dersler.length) {
                      final ders = _dersler[index];
                      HapticFeedback.selectionClick();
                      _selectDers(
                        ders['dersID'] as String,
                        ders['dersAdi'] as String,
                      );
                    }
                  }
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < _dersler.length) {
                        final ders = _dersler[value.toInt()];
                        final dersAdi = ders['dersAdi'] as String? ?? '';
                        final isSelected = ders['dersID'] == _selectedDersId;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dersAdi.length > 6
                                ? '${dersAdi.substring(0, 6)}.'
                                : dersAdi,
                            style: TextStyle(
                              color: isSelected ? Colors.amber : Colors.white70,
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '%${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white54,
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
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              barGroups: _buildLessonBarGroups(),
            ),
          ),
        )
        .animate()
        .scaleY(
          begin: 0.0,
          end: 1.0,
          duration: 800.ms,
          curve: Curves.easeOutBack,
          alignment: Alignment.bottomCenter,
        )
        .fadeIn(duration: 400.ms);
  }

  List<BarChartGroupData> _buildLessonBarGroups() {
    final List<Color> colors = [
      const Color(0xFF667eea),
      const Color(0xFFf093fb),
      const Color(0xFF00E676),
      const Color(0xFFFFD600),
      const Color(0xFFFF5E62),
      const Color(0xFF00BCD4),
    ];

    return _dersler.asMap().entries.map((entry) {
      final index = entry.key;
      final ders = entry.value;
      final dersId = ders['dersID'] as String;
      final basari = _dersBasariOranlari[dersId] ?? 0.0;
      final isSelected = dersId == _selectedDersId;
      final color = colors[index % colors.length];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: basari,
            width: isSelected ? 22 : 18,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color.withValues(alpha: 0.7), color],
            ),
            borderSide: isSelected
                ? const BorderSide(color: Colors.amber, width: 2)
                : BorderSide.none,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildReportButton(bool isDarkMode) {
    // Düşük başarılı konuları bul
    final dusukKonular = _konular.where((konu) {
      final basari = _konuBasariOranlari[konu['konuID']] ?? 0.0;
      return basari < 60;
    }).toList();

    return GestureDetector(
      onTap: () {
        if (_selectedDersId == null) {
          _showSelectionWarning();
          return;
        }
        _showReportModal();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withValues(alpha: 0.6),
              Colors.blue.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.fileLines,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'Rapor Görüntüle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dusukKonular.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${dusukKonular.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  void _showSelectionWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF24243e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('Hey, Dur Bakalım! 🛑', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Hangi dersin raporunu istiyorsun? Önce grafikten bir ders seç, sonra senin için harika bir rapor hazırlayayım! 😄',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam, Seçiyorum! 👍',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportModal(
        dersAdi: _selectedDersAdi ?? 'Ders',
        tumKonular: _konular,
        konuBasariOranlari: _konuBasariOranlari,
        konuCozulduMu: _konuCozulduMu,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.chartPie,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz veri yok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test çözdükten sonra burada\ngelişimini takip edebilirsin!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rapor Modalı - Geliştirilmiş Versiyon
class _ReportModal extends StatelessWidget {
  final String dersAdi;
  final List<Map<String, dynamic>> tumKonular;
  final Map<String, double> konuBasariOranlari;
  final Map<String, bool> konuCozulduMu;

  const _ReportModal({
    required this.dersAdi,
    required this.tumKonular,
    required this.konuBasariOranlari,
    required this.konuCozulduMu,
  });

  // Renk şeması
  static const Color _grayColor = Color(0xFF6B7280); // Hiç çözülmemiş
  static const Color _bordoColor = Color(0xFF7F1D1D); // %0-25
  static const Color _redColor = Color(0xFFDC2626); // %26-50
  static const Color _yellowColor = Color(0xFFFBBF24); // %51-75
  static const Color _greenColor = Color(0xFF10B981); // %76-100

  Color _getColorForTopic(String konuId) {
    final cozuldu = konuCozulduMu[konuId] ?? false;
    if (!cozuldu) return _grayColor;

    final basari = konuBasariOranlari[konuId] ?? 0.0;
    if (basari <= 25) return _bordoColor;
    if (basari <= 50) return _redColor;
    if (basari <= 75) return _yellowColor;
    return _greenColor;
  }

  String _getMotivationalMessage(String konuId) {
    final cozuldu = konuCozulduMu[konuId] ?? false;

    if (!cozuldu) {
      final messages = [
        '🌟 Bu konuya henüz hiç bakmadın! Keşfetmeye ne dersin?',
        '🚀 Yeni bir macera seni bekliyor! Bu konuyu keşfet!',
        '💫 Burada gizli hazineler var! İlk adımı atmaya hazır mısın?',
        '🎯 Henüz dokunulmamış bir konu! Şampiyonluğa ilk adım...',
        '✨ Bu konu seni bekliyor! Hadi başlayalım!',
      ];
      return messages[konuId.hashCode.abs() % messages.length];
    }

    final basari = konuBasariOranlari[konuId] ?? 0.0;

    if (basari <= 25) {
      final messages = [
        '🔥 Bu konu zorlu ama sen daha zorlusun! Tekrar dene!',
        '💪 Düşmek kalkmaktır! Bu konuyu fethedeceksin!',
        '🎯 Hedefine odaklan! Her yanlış seni doğruya yaklaştırır!',
        '⚡ Enerji topla ve bu konuya saldır! Başaracaksın!',
        '🌈 Fırtına dinecek, güneş açacak! Çalışmaya devam!',
      ];
      return messages[konuId.hashCode.abs() % messages.length];
    }

    if (basari <= 50) {
      final messages = [
        '📚 Yarı yoldasın! Biraz daha çaba göster!',
        '🔑 Kapıyı açmak üzeresin! Devam et!',
        '🏃 Koşmaya devam! Hedef yakın!',
        '💡 Potansiyelin var! Sadece biraz daha pratik!',
        '🌱 Tohum atıldı, şimdi büyütme zamanı!',
      ];
      return messages[konuId.hashCode.abs() % messages.length];
    }

    if (basari <= 75) {
      final messages = [
        '⭐ Harika gidiyorsun! Mükemmelliğe az kaldı!',
        '🎖️ Neredeyse şampiyon! Son hamle senin!',
        '🚀 Kalkış başarılı! Şimdi zirveye doğru!',
        '🏆 Podyuma çok yakınsın! Devam!',
        '✨ Parlıyorsun! Tam gaz devam!',
      ];
      return messages[konuId.hashCode.abs() % messages.length];
    }

    // %76-100
    final messages = [
      '🏆 MUHTEŞEM! Bu konunun ustası oldun!',
      '👑 KRAL/KRALİÇE! Bu konu senin oyun alanın!',
      '🌟 YILDIZ! Başarın göz kamaştırıyor!',
      '🎯 TAM İSABET! Bu konuda rakipsizsin!',
      '💎 ELİT! Başarın paha biçilemez!',
    ];
    return messages[konuId.hashCode.abs() % messages.length];
  }

  List<Map<String, dynamic>> _getSortedTopics() {
    final sorted = List<Map<String, dynamic>>.from(tumKonular);
    sorted.sort((a, b) {
      final aId = a['konuID'] as String;
      final bId = b['konuID'] as String;
      final aCozuldu = konuCozulduMu[aId] ?? false;
      final bCozuldu = konuCozulduMu[bId] ?? false;

      // Çözülenler en üste
      if (aCozuldu && !bCozuldu) return -1;
      if (!aCozuldu && bCozuldu) return 1;

      // Sonra başarı oranına göre (düşükten yükseğe)
      final aBasari = konuBasariOranlari[aId] ?? 0.0;
      final bBasari = konuBasariOranlari[bId] ?? 0.0;
      return aBasari.compareTo(bBasari);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sortedTopics = _getSortedTopics();
    final worstTopics = sortedTopics.take(5).toList();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [const Color(0xFFffffff), const Color(0xFFf3f4f6)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context, isDarkMode),

          Divider(color: isDarkMode ? Colors.white12 : Colors.black12),

          // Renk Açıklaması
          _buildColorLegend(isDarkMode),

          // Content
          Expanded(child: _buildTopicList(context, worstTopics, isDarkMode)),

          // Alt Buton
          if (sortedTopics.length > 5)
            _buildShowAllButton(context, sortedTopics, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.fileLines,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gelişim Raporu',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$dersAdi - En Kritik 5 Konu',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegend(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(_grayColor, 'Yeni', isDarkMode),
          _buildLegendItem(_bordoColor, '0-25', isDarkMode),
          _buildLegendItem(_redColor, '26-50', isDarkMode),
          _buildLegendItem(_yellowColor, '51-75', isDarkMode),
          _buildLegendItem(_greenColor, '76+', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicList(
    BuildContext context,
    List<Map<String, dynamic>> topics,
    bool isDarkMode,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final konu = topics[index];
        final konuId = konu['konuID'] as String;
        final konuAdi = konu['konuAdi'] as String? ?? 'Konu';
        final cozuldu = konuCozulduMu[konuId] ?? false;
        final basari = konuBasariOranlari[konuId] ?? 0.0;
        final color = _getColorForTopic(konuId);
        final message = _getMotivationalMessage(konuId);

        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                    color.withValues(alpha: isDarkMode ? 0.05 : 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Başarı Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            cozuldu ? '%${basari.toStringAsFixed(0)}' : 'YENİ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Konu Adı
                        Expanded(
                          child: Text(
                            konuAdi,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // İkon
                        Icon(
                          cozuldu
                              ? (basari >= 76
                                    ? Icons.emoji_events
                                    : Icons.trending_up)
                              : Icons.help_outline,
                          color: color,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Motivasyonel Mesaj
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.black87,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: index * 100))
            .fadeIn()
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildShowAllButton(
    BuildContext context,
    List<Map<String, dynamic>> allTopics,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FullReportScreen(
                dersAdi: dersAdi,
                tumKonular: allTopics,
                konuBasariOranlari: konuBasariOranlari,
                konuCozulduMu: konuCozulduMu,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.listCheck, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Tüm Raporu Göster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tam Rapor Ekranı
class _FullReportScreen extends StatelessWidget {
  final String dersAdi;
  final List<Map<String, dynamic>> tumKonular;
  final Map<String, double> konuBasariOranlari;
  final Map<String, bool> konuCozulduMu;

  const _FullReportScreen({
    required this.dersAdi,
    required this.tumKonular,
    required this.konuBasariOranlari,
    required this.konuCozulduMu,
  });

  static const Color _grayColor = Color(0xFF6B7280);
  static const Color _bordoColor = Color(0xFF7F1D1D);
  static const Color _redColor = Color(0xFFDC2626);
  static const Color _yellowColor = Color(0xFFFBBF24);
  static const Color _greenColor = Color(0xFF10B981);

  Color _getColorForTopic(String konuId) {
    final cozuldu = konuCozulduMu[konuId] ?? false;
    if (!cozuldu) return _grayColor;

    final basari = konuBasariOranlari[konuId] ?? 0.0;
    if (basari <= 25) return _bordoColor;
    if (basari <= 50) return _redColor;
    if (basari <= 75) return _yellowColor;
    return _greenColor;
  }

  String _getMotivationalMessage(String konuId) {
    final cozuldu = konuCozulduMu[konuId] ?? false;

    if (!cozuldu) {
      return '🌟 Bu konuya henüz hiç bakmadın! Keşfetmeye ne dersin?';
    }

    final basari = konuBasariOranlari[konuId] ?? 0.0;

    if (basari <= 25) return '🔥 Bu konu zorlu ama sen daha zorlusun!';
    if (basari <= 50) return '📚 Yarı yoldasın! Biraz daha çaba göster!';
    if (basari <= 75) return '⭐ Harika gidiyorsun! Mükemmelliğe az kaldı!';
    return '🏆 MUHTEŞEM! Bu konunun ustası oldun!';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        title: Text(
          '$dersAdi - Tam Rapor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0f0c29),
                    const Color(0xFF302b63),
                    const Color(0xFF24243e),
                  ]
                : [
                    const Color(0xFFffffff),
                    const Color(0xFFf3f4f6),
                    const Color(0xFFe5e7eb),
                  ],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: tumKonular.length,
            itemBuilder: (context, index) {
              final konu = tumKonular[index];
              final konuId = konu['konuID'] as String;
              final konuAdi = konu['konuAdi'] as String? ?? 'Konu';
              final cozuldu = konuCozulduMu[konuId] ?? false;
              final basari = konuBasariOranlari[konuId] ?? 0.0;
              final color = _getColorForTopic(konuId);
              final message = _getMotivationalMessage(konuId);

              return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cozuldu ? '%${basari.toStringAsFixed(0)}' : 'YENİ',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                konuAdi,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.05, end: 0, duration: 200.ms);
            },
          ),
        ),
      ),
    );
  }
}
