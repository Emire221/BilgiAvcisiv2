import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/duel_entities.dart';

/// Test sorusu widget'ı - Responsive tasarım
class DuelTestQuestion extends StatelessWidget {
  final DuelQuestion question;
  final int? userSelectedIndex;
  final int? botSelectedIndex;
  final bool isAnswered;
  final Function(int) onAnswerSelected;

  // Tema renkleri
  static const Color _neonCyan = Color(0xFF00F5FF);

  const DuelTestQuestion({
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
        // Ekran boyutuna göre dinamik ayarlar
        final isSmallScreen = constraints.maxHeight < 400;
        final questionFontSize = isSmallScreen ? 14.0 : 16.0;
        final optionFontSize = isSmallScreen ? 14.0 : 15.0;
        final optionPadding = isSmallScreen ? 10.0 : 14.0;
        
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
              
              // Soru metni - Esnek yükseklik
              Container(
                constraints: BoxConstraints(
                  minHeight: 60,
                  maxHeight: screenHeight * 0.25, // Ekranın max %25'i
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    question.question.isNotEmpty 
                        ? question.question 
                        : 'Soru yükleniyor...',
                    style: GoogleFonts.nunito(
                      fontSize: questionFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Şıklar - Her biri esnek yükseklikte
              ...List.generate(
                question.options.length,
                (index) => _buildOptionButton(
                  context, 
                  index, 
                  optionFontSize, 
                  optionPadding,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context, 
    int index, 
    double fontSize,
    double padding,
  ) {
    final isCorrect = index == question.correctIndex;
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: isAnswered ? null : () => onAnswerSelected(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: padding),
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
            children: [
              // Şık harfi
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Seçenek metni - Esnek ve çok satırlı
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    height: 1.3,
                  ),
                  // Uzun metinler için sınırsız satır
                  softWrap: true,
                ),
              ),

              // İşaretler
              if (isAnswered) ...[
                const SizedBox(width: 8),
                if (isUserSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                if (isBotSelected) ...[
                  if (isUserSelected) const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
