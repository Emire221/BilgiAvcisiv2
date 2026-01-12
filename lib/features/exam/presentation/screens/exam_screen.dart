import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/models/trial_exam.dart';
import '../../../../services/database_helper.dart';

/// Sınav ekranı - Wireframe modu (minimal UI, maksimum fonksiyonellik)
class ExamScreen extends StatefulWidget {
  final TrialExam exam;

  const ExamScreen({super.key, required this.exam});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final PageController _pageController = PageController();
  final Map<String, String> _answers = {};
  late int _remainingSeconds;
  Timer? _timer;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    // ⚡ Sınav sırasında ekranın kapanmasını engelle
    WakelockPlus.enable();
    _remainingSeconds = widget.exam.duration * 60; // Dakika -> Saniye
    _startTimer();
  }

  @override
  void dispose() {
    // ⚡ Ekran kapanmasına izin ver
    WakelockPlus.disable();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishExam();
        }
      });
    });
  }

  void _selectAnswer(String questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  Future<void> _finishExam() async {
    _timer?.cancel();

    // Cevapları veritabanına kaydet
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Boş bırakılan soruları "EMPTY" olarak işaretle
    final allAnswers = <String, String>{};
    for (var i = 0; i < widget.exam.questions.length; i++) {
      final questionId = (i + 1).toString();
      allAnswers[questionId] = _answers[questionId] ?? 'EMPTY';
    }

    // Puanı hesapla
    int score = 0;
    for (var i = 0; i < widget.exam.questions.length; i++) {
      final questionId = (i + 1).toString();
      final userAnswer = allAnswers[questionId];
      final correctAnswer = widget.exam.questions[i].correctAnswer;

      if (userAnswer == correctAnswer) {
        score += (100 / widget.exam.questions.length).round();
      }
    }

    // Veritabanına kaydet
    final db = await DatabaseHelper().database;
    await db.insert('TrialResults', {
      'examId': widget.exam.id,
      'userId': user.uid,
      'rawAnswers': json.encode(allAnswers),
      'score': score,
      'completedAt': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    // Kullanıcıyı bilgilendir ve ana sayfaya dön
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cevapların alındı! Sonuçlar Cumartesi 12:00\'de açıklanacak.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sınavı Bırak'),
            content: const Text('Sınavdan çıkmak istediğine emin misin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Evet'),
              ),
            ],
          ),
        );
        if (shouldPop ?? false) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exam.title),
          actions: [
            // Countdown Timer
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds < 300
                        ? Colors.red
                        : Colors.white, // Son 5 dakika kırmızı
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.exam.questions.length,
            ),
            // Soru Gösterimi
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: widget.exam.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.exam.questions[index];
                  final questionId = (index + 1).toString();
                  final selectedAnswer = _answers[questionId];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Soru Numarası
                        Text(
                          'Soru ${index + 1}/${widget.exam.questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Soru Metni
                        Text(
                          question.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Şıklar
                        ...['A', 'B', 'C', 'D'].asMap().entries.map((entry) {
                          final optionLetter = entry.key;
                          final optionText = question.options[optionLetter];
                          final letter = String.fromCharCode(65 + optionLetter);
                          final isSelected = selectedAnswer == letter;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _selectAnswer(questionId, letter),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Şık Harfi
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          letter,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Şık Metni
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Alt Navigasyon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri Butonu
                  if (_currentQuestionIndex > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Geri'),
                    )
                  else
                    const SizedBox(),
                  // İleri / Bitir Butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_currentQuestionIndex <
                          widget.exam.questions.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _showFinishDialog();
                      }
                    },
                    icon: Icon(
                      _currentQuestionIndex < widget.exam.questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                    ),
                    label: Text(
                      _currentQuestionIndex < widget.exam.questions.length - 1
                          ? 'İleri'
                          : 'Bitir',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _currentQuestionIndex <
                              widget.exam.questions.length - 1
                          ? null
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavı Bitir'),
        content: Text(
          'Toplam ${widget.exam.questions.length} sorudan ${_answers.length} tanesini cevapladın.\n\nSınavı bitirmek istediğine emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
