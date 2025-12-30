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
    final screenHeight = MediaQuery.of(context).size.height;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 400;
        final sentenceFontSize = isSmallScreen ? 18.0 : 22.0;
        final optionFontSize = isSmallScreen ? 14.0 : 16.0;
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Konu Adı (varsa)
              if (question.topicName != null && question.topicName!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Icon(Icons.topic_rounded, color: _neonCyan, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          question.topicName!,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
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
              
              // Cümle - Esnek yükseklik
              Container(
                constraints: BoxConstraints(
                  minHeight: 80,
                  maxHeight: screenHeight * 0.30, // Ekranın max %30'u
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: sentenceFontSize,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      children: _buildSentenceSpans(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Seçenekler (Grid) - Responsive
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isSmallScreen ? 2.8 : 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(question.options.length, (index) {
                  return _buildOptionButton(context, index, optionFontSize);
                }),
              ),
            ],
          ),
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

  Widget _buildOptionButton(BuildContext context, int index, double fontSize) {
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
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
              ),
            ),

            // İşaretler
            if (isAnswered) ...[
              const SizedBox(width: 4),
              if (isUserSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              if (isBotSelected) ...[
                if (isUserSelected) const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 12,
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
