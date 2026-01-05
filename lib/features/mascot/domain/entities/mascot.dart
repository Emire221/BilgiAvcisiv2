import 'package:flutter/material.dart';

// Maskot türleri
enum PetType {
  astronaut,
  monkey,
  tiger,
  cat,
  dog,
  rabbit;

  String get displayName {
    switch (this) {
      case PetType.cat:
        return 'Kedi';
      case PetType.dog:
        return 'Köpek';
      case PetType.rabbit:
        return 'Tavşan';
      case PetType.astronaut:
        return 'Astronot';
      case PetType.tiger:
        return 'Kaplan';
      case PetType.monkey:
        return 'Maymun';
    }
  }

  /// Lottie animasyon dosya yolu
  String getLottiePath() {
    switch (this) {
      case PetType.cat:
        return 'assets/animation/kedi_mascot.json';
      case PetType.dog:
        return 'assets/animation/kopek_mascot.json';
      case PetType.rabbit:
        return 'assets/animation/tavsan_mascot.json';
      case PetType.astronaut:
        return 'assets/animation/astronot_mascot.json';
      case PetType.tiger:
        return 'assets/animation/kaplan_mascot.json';
      case PetType.monkey:
        return 'assets/animation/maymun_mascot.json';
    }
  }

  /// Maskot rengi
  Color get color {
    switch (this) {
      case PetType.cat:
        return const Color(0xFFFF6B9D); // Pembe
      case PetType.dog:
        return const Color(0xFFFFB347); // Turuncu
      case PetType.rabbit:
        return const Color(0xFF87CEEB); // Açık Mavi
      case PetType.astronaut:
        return const Color(0xFF9B59B6); // Mor
      case PetType.tiger:
        return const Color(0xFFE74C3C); // Kırmızı-Turuncu
      case PetType.monkey:
        return const Color(0xFF8B4513); // Kahverengi
    }
  }
}

// Maskot varlığı
class Mascot {
  final int? id;
  final PetType petType;
  final String petName;
  final int currentXp;
  final int level;
  final int mood;
  final DateTime createdAt;

  Mascot({
    this.id,
    required this.petType,
    required this.petName,
    this.currentXp = 0,
    this.level = 1,
    this.mood = 100,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Mascot copyWith({
    int? id,
    PetType? petType,
    String? petName,
    int? currentXp,
    int? level,
    int? mood,
    DateTime? createdAt,
  }) {
    return Mascot(
      id: id ?? this.id,
      petType: petType ?? this.petType,
      petName: petName ?? this.petName,
      currentXp: currentXp ?? this.currentXp,
      level: level ?? this.level,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petType': petType.name,
      'petName': petName,
      'currentXp': currentXp,
      'level': level,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Mascot.fromMap(Map<String, dynamic> map) {
    return Mascot(
      id: map['id'] as int?,
      petType: PetType.values.firstWhere(
        (e) => e.name == map['petType'],
        orElse: () => PetType.cat, // Varsayılan cat
      ),
      petName: map['petName'] as String,
      currentXp: map['currentXp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      mood: map['mood'] as int? ?? 100,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
