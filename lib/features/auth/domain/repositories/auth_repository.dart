import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth işlemlerini soyutlayan repository interface
abstract class AuthRepository {
  /// Kullanıcı kimlik doğrulama durumu stream'i
  Stream<User?> get authStateChanges;

  /// Mevcut kullanıcıyı döndürür
  User? get currentUser;

  /// Email ve şifre ile giriş yapar
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Email ve şifre ile yeni kullanıcı kaydı oluşturur
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Kullanıcı çıkışı yapar
  Future<void> signOut();

  /// Şifre sıfırlama e-postası gönderir
  Future<void> sendPasswordResetEmail({required String email});
}
