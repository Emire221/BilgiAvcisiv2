import '../../../mascot/domain/entities/mascot.dart';

/// Bot profil bilgilerini tutan entity
class BotProfile {
  final String name;
  final String avatar;
  final int level;
  final PetType mascotType;

  const BotProfile({
    required this.name,
    required this.avatar,
    this.level = 1,
    required this.mascotType,
  });

  /// Türk erkek ve kadın isimlerinden rastgele bot ismi üretir
  static const List<String> _maleNames = [
    'Ahmet',
    'Mehmet',
    'Mustafa',
    'Ali',
    'Hüseyin',
    'Hasan',
    'İbrahim',
    'İsmail',
    'Osman',
    'Yusuf',
    'Ömer',
    'Murat',
    'Emre',
    'Burak',
    'Cem',
    'Deniz',
    'Efe',
    'Fatih',
    'Gökhan',
    'Halil',
    'Kaan',
    'Kerem',
    'Koray',
    'Onur',
    'Serkan',
    'Tolga',
    'Uğur',
    'Volkan',
    'Yasin',
    'Yiğit',
    'Baran',
    'Barış',
    'Can',
    'Çağrı',
    'Doruk',
    'Ege',
    'Eren',
    'Furkan',
    'Görkem',
    'Harun',
    'Ilgaz',
    'Kağan',
    'Levent',
    'Mert',
    'Oğuz',
    'Polat',
    'Rüzgar',
    'Selim',
    'Taner',
    'Ufuk',
  ];

  static const List<String> _femaleNames = [
    'Ayşe',
    'Fatma',
    'Zeynep',
    'Elif',
    'Esra',
    'Merve',
    'Gizem',
    'Büşra',
    'Seda',
    'Derya',
    'Gamze',
    'Hande',
    'İrem',
    'Kübra',
    'Melis',
    'Nazlı',
    'Özge',
    'Pelin',
    'Selin',
    'Tuğba',
    'Yağmur',
    'Aslı',
    'Başak',
    'Ceren',
    'Damla',
    'Ebru',
    'Fulya',
    'Gül',
    'Hilal',
    'Işıl',
    'Jale',
    'Kardelen',
    'Lale',
    'Melek',
    'Naz',
    'Nur',
    'Oya',
    'Pınar',
    'Reyhan',
    'Sevgi',
    'Şule',
    'Tuba',
    'Ülkü',
    'Vildan',
    'Yasemin',
    'Zara',
    'Beren',
    'Cansu',
    'Dilan',
    'Eylül',
  ];

  static const List<String> _lastInitials = [
    'A',
    'B',
    'C',
    'Ç',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'İ',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'Ö',
    'P',
    'R',
    'S',
    'Ş',
    'T',
    'U',
    'Ü',
    'V',
    'Y',
    'Z',
  ];

  static const List<String> _avatars = [
    '👤',
    '🧑',
    '👨',
    '👩',
    '🧒',
    '👦',
    '👧',
    '🧑‍🎓',
    '👨‍🎓',
    '👩‍🎓',
  ];

  /// Rastgele bir bot profili oluşturur
  /// [userLevel] - Kullanıcının seviyesi (bot seviyesi buna göre belirlenir)
  factory BotProfile.random({int userLevel = 1}) {
    final random = DateTime.now().microsecondsSinceEpoch;

    // Erkek veya kadın ismi seç (50-50)
    final isMale = random % 2 == 0;
    final names = isMale ? _maleNames : _femaleNames;

    final nameIndex = random % names.length;
    final lastInitialIndex = (random ~/ 100) % _lastInitials.length;
    final avatarIndex = (random ~/ 1000) % _avatars.length;

    // Bot seviyesi: Kullanıcı seviyesi veya +1 (alternatif olarak değişir)
    // random sayısının bir bitine göre 0 veya 1 ekle
    final levelBonus = (random ~/ 10000) % 2; // 0 veya 1
    final level = userLevel + levelBonus;

    final fullName = '${names[nameIndex]} ${_lastInitials[lastInitialIndex]}.';

    // Rastgele maskot seç
    final mascotIndex = (random ~/ 20000) % PetType.values.length;
    final mascot = PetType.values[mascotIndex];

    return BotProfile(
      name: fullName,
      avatar: _avatars[avatarIndex],
      level: level,
      mascotType: mascot,
    );
  }
}
