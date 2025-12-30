import 'dart:convert';

class School {
  final String okulID;
  final String okulAdi;
  final String il;
  final String ilce;

  School({
    required this.okulID,
    required this.okulAdi,
    required this.il,
    required this.ilce,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      okulID: json['okulID'] ?? '',
      okulAdi: json['okulAdi'] ?? '',
      il: json['il'] ?? '',
      ilce: json['ilce'] ?? '',
    );
  }
}

class Lesson {
  final String dersID;
  final String dersAdi;
  final String ikon;
  final String renk;

  Lesson({
    required this.dersID,
    required this.dersAdi,
    required this.ikon,
    required this.renk,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      dersID: json['dersID'] ?? '',
      dersAdi: json['dersAdi'] ?? '',
      ikon: json['ikon'] ?? '',
      renk: json['renk'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'dersID': dersID, 'dersAdi': dersAdi, 'ikon': ikon, 'renk': renk};
  }
}

class Topic {
  final String konuID;
  final String dersID;
  final String konuAdi;
  final int sira;

  Topic({
    required this.konuID,
    required this.dersID,
    required this.konuAdi,
    required this.sira,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      konuID: json['konuID'] ?? '',
      dersID: json['dersID'] ?? '',
      konuAdi: json['konuAdi'] ?? '',
      sira: json['sira'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'konuID': konuID,
      'dersID': dersID,
      'konuAdi': konuAdi,
      'sira': sira,
    };
  }
}

class Test {
  final String testID;
  final String konuID;
  final String testAdi;
  final int zorluk;
  final String cozumVideoURL;
  final List<dynamic> sorular;

  Test({
    required this.testID,
    required this.konuID,
    required this.testAdi,
    required this.zorluk,
    required this.cozumVideoURL,
    required this.sorular,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      testID: json['testID'] ?? '',
      konuID: json['konuID'] ?? '',
      testAdi: json['testAdi'] ?? '',
      zorluk: json['zorluk'] ?? 1,
      cozumVideoURL: json['cozumVideoURL'] ?? '',
      sorular: json['sorular'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testID': testID,
      'konuID': konuID,
      'testAdi': testAdi,
      'zorluk': zorluk,
      'cozumVideoURL': cozumVideoURL,
      'sorular': jsonEncode(sorular),
    };
  }
}

class FlashcardSet {
  final String kartSetID;
  final String konuID;
  final String kartAdi;
  final List<dynamic> kartlar;

  FlashcardSet({
    required this.kartSetID,
    required this.konuID,
    required this.kartAdi,
    required this.kartlar,
  });

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      kartSetID: json['kartSetID'] ?? '',
      konuID: json['konuID'] ?? '',
      kartAdi: json['kartAdi'] ?? '',
      kartlar: json['kartlar'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kartSetID': kartSetID,
      'konuID': konuID,
      'kartAdi': kartAdi,
      'kartlar': jsonEncode(kartlar),
    };
  }
}

class Video {
  final String videoID;
  final String konuID;
  final String videoBaslik;
  final String youtubeURL;
  final String sure;

  Video({
    required this.videoID,
    required this.konuID,
    required this.videoBaslik,
    required this.youtubeURL,
    required this.sure,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoID: json['videoID'] ?? '',
      konuID: json['konuID'] ?? '',
      videoBaslik: json['videoBaslik'] ?? '',
      youtubeURL: json['youtubeURL'] ?? '',
      sure: json['sure'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoID': videoID,
      'konuID': konuID,
      'videoBaslik': videoBaslik,
      'youtubeURL': youtubeURL,
      'sure': sure,
    };
  }
}
