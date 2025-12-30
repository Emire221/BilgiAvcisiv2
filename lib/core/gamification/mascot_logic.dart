import '../../features/mascot/domain/entities/mascot.dart';

/// Maskot oyunlaştırma mantığı
class MascotLogic {
  // Her 100 XP'de 1 level atlama
  static const int xpPerLevel = 100;

  /// XP'ye göre seviye hesapla (her 100 XP = 1 level)
  static int calculateLevel(int xp) {
    // 0-99 XP = Level 1, 100-199 XP = Level 2, vs.
    return (xp ~/ xpPerLevel) + 1;
  }

  /// Bir sonraki seviyeye kalan XP
  static int xpToNextLevel(int currentXp, int currentLevel) {
    final nextLevelXp = currentLevel * xpPerLevel;
    return nextLevelXp - currentXp;
  }

  /// Mevcut seviyenin başlangıç XP'si
  static int currentLevelStartXp(int level) {
    return (level - 1) * xpPerLevel;
  }

  /// Seviye ilerleme yüzdesi (0-1 arası)
  static double getLevelProgress(int currentXp, int currentLevel) {
    final currentLevelStart = currentLevelStartXp(currentLevel);
    final nextLevelStart = currentLevel * xpPerLevel;
    final levelRange = nextLevelStart - currentLevelStart;

    if (levelRange == 0) return 1.0;

    final progress = (currentXp - currentLevelStart) / levelRange;
    return progress.clamp(0.0, 1.0);
  }

  /// XP ekleyip seviye kontrolü yap
  static MascotLevelResult addXp(Mascot mascot, int xpAmount) {
    final newXp = mascot.currentXp + xpAmount;
    final oldLevel = mascot.level;
    final newLevel = calculateLevel(newXp);
    final leveledUp = newLevel > oldLevel;

    final updatedMascot = mascot.copyWith(currentXp: newXp, level: newLevel);

    return MascotLevelResult(
      mascot: updatedMascot,
      leveledUp: leveledUp,
      oldLevel: oldLevel,
      newLevel: newLevel,
    );
  }

  /// Seviyeye göre asset yolu
  static String getMascotAssetPath(String petType, int level) {
    String stage;

    if (level <= 3) {
      stage = 'baby';
    } else if (level <= 6) {
      stage = 'teen';
    } else {
      stage = 'wise';
    }

    return 'assets/mascot/${petType}_$stage.png';
  }

  /// Yumurta asset yolu
  static String getEggAssetPath(String petType) {
    return 'assets/mascot/egg_$petType.png';
  }
}

/// XP ekleme sonucu
class MascotLevelResult {
  final Mascot mascot;
  final bool leveledUp;
  final int oldLevel;
  final int newLevel;

  const MascotLevelResult({
    required this.mascot,
    required this.leveledUp,
    required this.oldLevel,
    required this.newLevel,
  });
}
