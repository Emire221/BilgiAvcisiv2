import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/mascot.dart';
import '../providers/mascot_provider.dart';
import '../../../../core/gamification/mascot_logic.dart';
import '../../../../core/gamification/mascot_phrases.dart';
import '../../../../core/providers/user_provider.dart';

class MascotWidget extends ConsumerStatefulWidget {
  const MascotWidget({super.key});

  @override
  ConsumerState<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends ConsumerState<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  String _currentPhrase = '';

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotAsync = ref.watch(activeMascotProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return mascotAsync.when(
      data: (mascot) {
        if (mascot == null) return const SizedBox.shrink();

        final userName =
            userProfileAsync.asData?.value?['name'] ?? 'Bilgi Avcısı';

        if (_currentPhrase.isEmpty) {
          _currentPhrase = MascotPhrases.getMotivation();
        }

        return _buildMascotCard(mascot, userName);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMascotCard(Mascot mascot, String userName) {
    final progress = MascotLogic.getLevelProgress(
      mascot.currentXp,
      mascot.level,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPetColor(mascot.petType).withValues(alpha: 0.3),
            _getPetColor(mascot.petType).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPetColor(mascot.petType).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _breatheAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breatheAnimation.value,
                child: _buildMascotAvatar(mascot),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentPhrase,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      mascot.petName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lvl ${mascot.level}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'XP: ${mascot.currentXp}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          mascot.level >= 10
                              ? 'Max!'
                              : '${MascotLogic.xpToNextLevel(mascot.currentXp, mascot.level)} kaldı',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPetColor(mascot.petType),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotAvatar(Mascot mascot) {
    final Color color = _getPetColor(mascot.petType);

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        clipBehavior: Clip.none, // Overflow/pop-out efekti için
        child: Transform.scale(
          scale: 1.3, // Maskotun biraz taşması için
          child: Lottie.asset(
            mascot.petType.getLottiePath(),
            width: 85,
            height: 85,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Color _getPetColor(PetType petType) {
    return petType.color;
  }
}
