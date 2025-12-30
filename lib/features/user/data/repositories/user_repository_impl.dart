import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_repository.dart';

/// UserRepository'nin Firestore implementasyonu
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String grade,
    required String city,
    required String district,
    required String schoolId,
    required String schoolName,
    String? avatar,
    String? email,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        if (email != null) 'email': email,
        'name': name,
        'grade': grade,
        'city': city,
        'district': district,
        'schoolId': schoolId,
        'schoolName': schoolName,
        'avatar': avatar ?? 'assets/images/avatar.png',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Kullanıcı profili kaydedilemedi: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı profili getirilemedi: $e');
    }
  }

  @override
  Future<String> getUserGrade(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['grade'] ?? '3. Sınıf';
      }
      return '3. Sınıf'; // Varsayılan
    } catch (e) {
      return '3. Sınıf'; // Hata durumunda varsayılan
    }
  }

  @override
  Future<void> saveTestResult({
    required String userId,
    required String testId,
    required String topicId,
    required String topicName,
    required int score,
    required int correctCount,
    required int wrongCount,
    int? duration,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('results')
          .add({
            'testId': testId,
            'topicId': topicId,
            'topicName': topicName,
            'score': score,
            'correctCount': correctCount,
            'wrongCount': wrongCount,
            'duration': duration,
            'date': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Test sonucu kaydedilemedi: $e');
    }
  }

  @override
  Future<int> getTotalScore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('results')
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc['score'] as int? ?? 0);
      }
      return total;
    } catch (e) {
      return 0; // Hata durumunda 0 döndür
    }
  }
}
