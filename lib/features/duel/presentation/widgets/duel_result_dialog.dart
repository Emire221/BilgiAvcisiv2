import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../logic/duel_controller.dart' show DuelResult;

/// Düello sonuç dialogu
class DuelResultDialog extends StatefulWidget {
  final DuelResult result;
  final int userScore;
  final int botScore;
  final String botName;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const DuelResultDialog({
    super.key,
    required this.result,
    required this.userScore,
    required this.botScore,
    required this.botName,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  State<DuelResultDialog> createState() => _DuelResultDialogState();
}

class _DuelResultDialogState extends State<DuelResultDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Kazandıysa confetti başlat
    if (widget.result == DuelResult.win) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 600;
    final iconSize = isCompact ? 40.0 : 60.0;
    final titleSize = isCompact ? 22.0 : 28.0;
    final subtitleSize = isCompact ? 14.0 : 16.0;
    final scoreFontSize = isCompact ? 20.0 : 24.0;
    final padding = isCompact ? 16.0 : 24.0;

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sonuç ikonu
                _buildResultIcon(iconSize, isCompact),

                SizedBox(height: isCompact ? 12 : 16),

                // Sonuç başlığı
                Text(
                  _getResultTitle(),
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: _getResultColor(),
                  ),
                ),

                SizedBox(height: isCompact ? 4 : 8),

                // Alt başlık
                Text(
                  _getResultSubtitle(),
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isCompact ? 16 : 24),

                // Skor özeti
                Container(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreColumn(
                        'Sen',
                        widget.userScore,
                        Colors.blue,
                        scoreFontSize,
                        isCompact,
                      ),
                      Container(
                        width: 2,
                        height: isCompact ? 40 : 50,
                        color: Colors.grey[300],
                      ),
                      _buildScoreColumn(
                        widget.botName,
                        widget.botScore,
                        Colors.orange,
                        scoreFontSize,
                        isCompact,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isCompact ? 16 : 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onExit,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Çık'),
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Yeni Düello'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultIcon(double iconSize, bool isCompact) {
    IconData icon;
    Color color;

    switch (widget.result) {
      case DuelResult.win:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case DuelResult.lose:
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case DuelResult.draw:
        icon = Icons.handshake;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }

  String _getResultTitle() {
    switch (widget.result) {
      case DuelResult.win:
        return '🎉 Kazandın!';
      case DuelResult.lose:
        return '😔 Kaybettin';
      case DuelResult.draw:
        return '🤝 Berabere';
    }
  }

  String _getResultSubtitle() {
    switch (widget.result) {
      case DuelResult.win:
        return 'Tebrikler! ${widget.botName}\'i yendin!';
      case DuelResult.lose:
        return '${widget.botName} bu sefer kazandı. Bir dahaki sefere!';
      case DuelResult.draw:
        return 'Bu çekişmeli bir maçtı!';
    }
  }

  Color _getResultColor() {
    switch (widget.result) {
      case DuelResult.win:
        return Colors.green;
      case DuelResult.lose:
        return Colors.red;
      case DuelResult.draw:
        return Colors.orange;
    }
  }

  Widget _buildScoreColumn(
    String name,
    int score,
    Color color,
    double fontSize,
    bool isCompact,
  ) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isCompact ? 6 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 14 : 20,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
