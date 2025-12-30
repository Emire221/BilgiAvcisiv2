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
    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sonuç ikonu
                _buildResultIcon(),

                const SizedBox(height: 16),

                // Sonuç başlığı
                Text(
                  _getResultTitle(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getResultColor(),
                  ),
                ),

                const SizedBox(height: 8),

                // Alt başlık
                Text(
                  _getResultSubtitle(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Skor özeti
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreColumn('Sen', widget.userScore, Colors.blue),
                      Container(width: 2, height: 50, color: Colors.grey[300]),
                      _buildScoreColumn(
                        widget.botName,
                        widget.botScore,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onExit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Çık'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildResultIcon() {
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 60, color: color),
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

  Widget _buildScoreColumn(String name, int score, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
