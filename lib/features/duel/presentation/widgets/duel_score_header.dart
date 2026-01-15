import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../mascot/domain/entities/mascot.dart';
import '../../../mascot/presentation/providers/mascot_provider.dart';
import '../../domain/entities/bot_profile.dart';

/// Düello skor header'ı - maskotlarla kompakt bar tasarımı
class DuelScoreHeader extends ConsumerStatefulWidget {
  final int userScore;
  final int botScore;
  final BotProfile? botProfile;
  final int currentQuestion;
  final int totalQuestions;
  final bool hideQuestionCounter;

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
  ConsumerState<DuelScoreHeader> createState() => _DuelScoreHeaderState();
}

class _DuelScoreHeaderState extends ConsumerState<DuelScoreHeader> {
  // Renk tanımları
  static const Color _userColor = Color(0xFF00D9FF); // Cyan
  static const Color _botColor = Color(0xFFFF6B35); // Orange

  @override
  Widget build(BuildContext context) {
    // Kullanıcı maskotunu al
    final mascotAsync = ref.watch(activeMascotProvider);
    final userMascot = mascotAsync.valueOrNull;
    final userPetType = userMascot?.petType ?? PetType.astronaut;

    final maxScore = widget.totalQuestions;
    final userProgress = maxScore > 0 ? widget.userScore / maxScore : 0.0;
    final botProgress = maxScore > 0 ? widget.botScore / maxScore : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana skor bar
          Row(
            children: [
              // Kullanıcı maskotu
              _buildMascotAvatar(userPetType, _userColor, true),

              const SizedBox(width: 8),

              // Kullanıcı skor bar
              Expanded(
                child: _buildScoreBar(
                  score: widget.userScore,
                  progress: userProgress,
                  color: _userColor,
                  isUser: true,
                ),
              ),

              // VS badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _userColor.withValues(alpha: 0.3),
                      _botColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'VS',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Bot skor bar
              Expanded(
                child: _buildScoreBar(
                  score: widget.botScore,
                  progress: botProgress,
                  color: _botColor,
                  isUser: false,
                ),
              ),

              const SizedBox(width: 8),

              // Bot maskotu
              _buildMascotAvatar(
                widget.botProfile?.mascotType ?? PetType.astronaut,
                _botColor,
                false,
              ),
            ],
          ),

          // Soru sayısı (opsiyonel)
          if (!widget.hideQuestionCounter) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Soru ${widget.currentQuestion} / ${widget.totalQuestions}',
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMascotAvatar(PetType petType, Color color, bool isUser) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.4),
            color.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Lottie.asset(
          petType.getLottiePath(),
          fit: BoxFit.cover,
          repeat: true,
        ),
      ),
    );
  }

  Widget _buildScoreBar({
    required int score,
    required double progress,
    required Color color,
    required bool isUser,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // İsim ve skor
        Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Text(
                '$score',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              isUser ? 'Sen' : (widget.botProfile?.name ?? 'Rakip'),
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUser) ...[
              const SizedBox(width: 6),
              Text(
                '$score',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),

        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUser
                            ? [color, color.withValues(alpha: 0.7)]
                            : [color.withValues(alpha: 0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
