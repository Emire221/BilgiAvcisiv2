import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/duel_entities.dart' as entities;

/// Cümle tamamlama sorusu widget'ı - Responsive tasarım
class DuelFillBlankQuestionWidget extends StatelessWidget {
  final entities.DuelFillBlankQuestion question;
  final int? userSelectedIndex;
  final int? botSelectedIndex;
  final bool isAnswered;
  final Function(int) onAnswerSelected;

  // Tema renkleri
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonGreen = Color(0xFF39FF14);

  const DuelFillBlankQuestionWidget({
    super.key,
    required this.question,
    this.userSelectedIndex,
    this.botSelectedIndex,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 400;
        final sentenceFontSize = isCompact ? 16.0 : 20.0;
        final optionFontSize = isCompact ? 13.0 : 15.0;

        // Proportional layout: Topic ~8%, Sentence ~40%, Options ~52%
        final topicHeight =
            question.topicName != null && question.topicName!.isNotEmpty
            ? (availableHeight * 0.08).clamp(32.0, 48.0)
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Konu Adı (varsa)
            if (question.topicName != null && question.topicName!.isNotEmpty)
              Container(
                height: topicHeight,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _neonCyan.withOpacity(0.2),
                      _neonCyan.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _neonCyan.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.topic_rounded, color: _neonCyan, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        question.topicName!,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _neonCyan,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Cümle - Flex 4
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: sentenceFontSize,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      children: _buildSentenceSpans(),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isCompact ? 12 : 16),

            // Seçenekler (Grid) - Flex 5
            Expanded(
              flex: 5,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: isCompact ? 8 : 12,
                crossAxisSpacing: isCompact ? 8 : 12,
                childAspectRatio: isCompact ? 3.0 : 2.5,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(question.options.length, (index) {
                  return _buildOptionButton(
                    context,
                    index,
                    optionFontSize,
                    isCompact,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> _buildSentenceSpans() {
    // Ardışık alt tireleri tek bir placeholder'a dönüştür
    final normalizedSentence = question.sentence.replaceAll(
      RegExp(r'_+'),
      '___BLANK___',
    );
    final parts = normalizedSentence.split('___BLANK___');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));

      if (i < parts.length - 1) {
        // Boşluk alanı
        String blankText = '______';
        TextStyle blankStyle = const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          decoration: TextDecoration.underline,
        );

        if (isAnswered) {
          blankText = question.answer;
          blankStyle = TextStyle(
            fontWeight: FontWeight.bold,
            color: _neonGreen,
          );
        } else if (userSelectedIndex != null) {
          blankText = question.options[userSelectedIndex!];
          blankStyle = const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          );
        }

        spans.add(TextSpan(text: blankText, style: blankStyle));
      }
    }

    return spans;
  }

  Widget _buildOptionButton(
    BuildContext context,
    int index,
    double fontSize,
    bool isCompact,
  ) {
    final option = question.options[index];
    final isCorrect = option == question.answer;
    final isUserSelected = userSelectedIndex == index;
    final isBotSelected = botSelectedIndex == index;

    Color backgroundColor = Colors.grey[100]!;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;

    // Cevaplandıktan sonra renkleri göster
    if (isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
        textColor = Colors.green[800]!;
      } else if (isUserSelected || isBotSelected) {
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red;
        textColor = Colors.red[800]!;
      }
    } else if (isUserSelected) {
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue;
      textColor = Colors.blue[800]!;
    }

    return InkWell(
      onTap: isAnswered ? null : () => onAnswerSelected(index),
      borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
          border: Border.all(color: borderColor, width: isCompact ? 1.5 : 2),
          boxShadow: [
            if (isUserSelected || (isAnswered && isCorrect))
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // İşaretler
            if (isAnswered) ...[
              const SizedBox(width: 4),
              if (isUserSelected)
                Container(
                  padding: EdgeInsets.all(isCompact ? 1 : 2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: isCompact ? 10 : 12,
                  ),
                ),
              if (isBotSelected) ...[
                if (isUserSelected) const SizedBox(width: 2),
                Container(
                  padding: EdgeInsets.all(isCompact ? 1 : 2),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: isCompact ? 10 : 12,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
