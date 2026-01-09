import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/mascot.dart';
import '../../data/services/talking_mascot_service.dart';
import '../providers/mascot_provider.dart';

/// TalkingMascotService için provider
final talkingMascotServiceProvider = Provider<TalkingMascotService>((ref) {
  final service = TalkingMascotService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Tam ekran interaktif maskot widget'ı - Talking Tom benzeri
class InteractiveMascotWidget extends ConsumerStatefulWidget {
  final double? height;
  final bool enableVoiceInteraction;

  const InteractiveMascotWidget({
    super.key,
    this.height,
    this.enableVoiceInteraction = true,
  });

  @override
  ConsumerState<InteractiveMascotWidget> createState() =>
      _InteractiveMascotWidgetState();
}

class _InteractiveMascotWidgetState
    extends ConsumerState<InteractiveMascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _talkingController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Idle animasyon (hafif sallanma)
    _idleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Konuşma animasyonu
    _talkingController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Zıplama animasyonu (dokunulduğunda)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _talkingController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _onTapDown() async {
    if (!widget.enableVoiceInteraction) return;

    _bounceController.forward();

    // Kayıt başlat
    final service = ref.read(talkingMascotServiceProvider);
    final started = await service.startRecording();

    if (started) {
      setState(() {
        _isRecording = true;
      });

      // Kayıt animasyonu başlat
      _talkingController.repeat(reverse: true);
    }
  }

  Future<void> _onTapUp() async {
    if (!widget.enableVoiceInteraction) return;

    _bounceController.reverse();

    if (_isRecording) {
      final service = ref.read(talkingMascotServiceProvider);
      await service.stopRecording();

      setState(() {
        _isRecording = false;
        _isPlaying = true;
      });

      // Sincap sesiyle çal
      await service.playRecordingWithPitchShift(
        pitchMultiplier: 1.6, // İnce ses
        speedMultiplier: 1.4, // Hızlı
        onComplete: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
            _talkingController.stop();
            _talkingController.reset();
          }
        },
      );
    }
  }

  void _onTapCancel() {
    setState(() {
      _isRecording = false;
    });
    _bounceController.reverse();
    _talkingController.stop();
    _talkingController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final mascotAsync = ref.watch(activeMascotProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final mascotHeight = widget.height ?? screenHeight * 0.45;

    return mascotAsync.when(
      data: (mascot) {
        if (mascot == null) return const SizedBox.shrink();
        return _buildMascot(mascot, mascotHeight);
      },
      loading: () => SizedBox(
        height: mascotHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMascot(Mascot mascot, double height) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _idleController]),
        builder: (context, child) {
          // Idle sallanma efekti
          final idleOffset = (_idleController.value - 0.5) * 10;

          // Konuşma/zıplama scale
          final scale = _bounceAnimation.value;

          return Transform.translate(
            offset: Offset(0, idleOffset),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow efekti
            if (_isRecording || _isPlaying)
              Container(
                width: height * 0.8,
                height: height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: mascot.petType.color.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

            // ✅ Maskot Lottie animasyonu - optimize edildi
            SizedBox(
              height: height,
              child: Lottie.asset(
                mascot.petType.getLottiePath(),
                fit: BoxFit.contain,
                animate: true,
                repeat: true,
                frameRate: FrameRate.max,
                options: LottieOptions(enableMergePaths: true),
              ),
            ),

            // Kayıt göstergesi
            if (_isRecording)
              Positioned(top: 10, child: _buildRecordingIndicator()),

            // Oynatma göstergesi
            if (_isPlaying)
              Positioned(top: 10, child: _buildPlayingIndicator()),

            // "Bana dokun" ipucu (ilk kullanım için) - Üste taşındı
            if (!_isRecording && !_isPlaying && widget.enableVoiceInteraction)
              Positioned(top: -35, child: _buildTouchHint()),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Dinliyorum...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Konuşuyorum!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchHint() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app, color: Colors.deepPurple, size: 18),
              SizedBox(width: 6),
              Text(
                'Basılı tut ve konuş',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Baloncuk ok işareti
        CustomPaint(size: const Size(16, 8), painter: _BubbleArrowPainter()),
      ],
    );
  }
}

/// Baloncuk ok işareti çizen painter
class _BubbleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
