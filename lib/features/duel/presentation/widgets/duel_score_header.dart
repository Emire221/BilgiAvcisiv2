import 'package:flutter/material.dart';
import '../../domain/entities/bot_profile.dart';

/// Düello skor header'ı - kullanıcı ve bot skorlarını gösterir
class DuelScoreHeader extends StatelessWidget {
  final int userScore;
  final int botScore;
  final BotProfile? botProfile;
  final int currentQuestion;
  final int totalQuestions;
  final bool hideQuestionCounter; // Memory oyunları için true

  const DuelScoreHeader({
    super.key,
    required this.userScore,
    required this.botScore,
    this.botProfile,
    required this.currentQuestion,
    required this.totalQuestions,
    this.hideQuestionCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Soru sayısı (Memory oyunlarında gizli)
          if (!hideQuestionCounter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Soru $currentQuestion / $totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (!hideQuestionCounter) const SizedBox(height: 16),

          // Skor kartları
          Row(
            children: [
              // Kullanıcı skoru
              Expanded(
                child: _buildScoreCard(
                  emoji: '👤',
                  name: 'Sen',
                  score: userScore,
                  isUser: true,
                ),
              ),

              // VS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),

              // Bot skoru
              Expanded(
                child: _buildScoreCard(
                  emoji: botProfile?.avatar ?? '🤖',
                  name: botProfile?.name ?? 'Rakip',
                  score: botScore,
                  isUser: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String emoji,
    required String name,
    required int score,
    required bool isUser,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
