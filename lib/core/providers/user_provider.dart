import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../services/local_preferences_service.dart';
import 'auth_provider.dart';

/// UserRepository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

/// LocalPreferencesService provider
final localPreferencesProvider = Provider<LocalPreferencesService>((ref) {
  return LocalPreferencesService();
});

/// Kullanıcı profili provider (Firestore + Local cache)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final localPrefs = ref.watch(localPreferencesProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  // Önce yerel cache'den dene
  final localProfile = await localPrefs.getUserProfile();
  if (localProfile['name'] != null) {
    return {
      'name': localProfile['name'],
      'grade': localProfile['grade'],
      'schoolName': localProfile['school'],
      'avatar': localProfile['avatar'],
      'city': localProfile['city'],
      'district': localProfile['district'],
    };
  }

  // Yoksa Firestore'dan çek ve cache'e kaydet
  final firestoreProfile = await userRepo.getUserProfile(currentUser.uid);
  if (firestoreProfile != null) {
    // ✅ Hem 'grade' hem 'classLevel' kontrol et (geriye dönük uyumluluk)
    final grade = firestoreProfile['grade'] ?? 
                  firestoreProfile['classLevel'] ?? 
                  '3. Sınıf';
    await localPrefs.saveUserProfile(
      name: firestoreProfile['name'] ?? '',
      grade: grade,
      school: firestoreProfile['schoolName'] ?? '',
      avatar: firestoreProfile['avatar'],
      city: firestoreProfile['city'],
      district: firestoreProfile['district'],
    );
  }

  return firestoreProfile;
});

/// Kullanıcı sınıfı provider
final userGradeProvider = FutureProvider<String>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return '3. Sınıf';

  final localPrefs = ref.watch(localPreferencesProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  // Önce yerel cache'den dene
  final localGrade = await localPrefs.getUserGrade();
  if (localGrade != null) return localGrade;

  // Yoksa Firestore'dan çek
  final grade = await userRepo.getUserGrade(currentUser.uid);
  await localPrefs.saveUserProfile(name: '', grade: grade, school: '');

  return grade;
});
