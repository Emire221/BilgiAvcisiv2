import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Şekil eşleştirme oyunu için şekil tanımları
class ShapeType {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ShapeType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  /// Okul figürleri - 5 farklı şekil
  static const List<ShapeType> schoolShapes = [
    ShapeType(
      id: 'ruler',
      name: 'Cetvel',
      icon: FontAwesomeIcons.rulerHorizontal,
      color: Color(0xFF4CAF50),
    ),
    ShapeType(
      id: 'pencil',
      name: 'Kalem',
      icon: FontAwesomeIcons.pencil,
      color: Color(0xFFFF9800),
    ),
    ShapeType(
      id: 'book',
      name: 'Kitap',
      icon: FontAwesomeIcons.bookOpen,
      color: Color(0xFF2196F3),
    ),
    ShapeType(
      id: 'calculator',
      name: 'Hesap Makinesi',
      icon: FontAwesomeIcons.calculator,
      color: Color(0xFF9C27B0),
    ),
    ShapeType(
      id: 'palette',
      name: 'Boya Paleti',
      icon: FontAwesomeIcons.palette,
      color: Color(0xFFE91E63),
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ShapeType && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// Şekil kartı modeli
class ShapeCard {
  final int id;              // Kartın pozisyon ID'si (0-9)
  final ShapeType shape;     // Kartın şekli
  final int pairId;          // Eş ID'si (0-4 arası, her şekilden 2 adet)
  final bool isFlipped;      // Kart açık mı?
  final bool isMatched;      // Doğru eşleşti mi?

  const ShapeCard({
    required this.id,
    required this.shape,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });

  ShapeCard copyWith({
    int? id,
    ShapeType? shape,
    int? pairId,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return ShapeCard(
      id: id ?? this.id,
      shape: shape ?? this.shape,
      pairId: pairId ?? this.pairId,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  String toString() =>
      'ShapeCard(id: $id, shape: ${shape.name}, pairId: $pairId, flipped: $isFlipped, matched: $isMatched)';
}
