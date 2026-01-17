import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/glass_container.dart';
import '../core/providers/user_provider.dart';
import '../services/database_helper.dart';
import '../services/local_preferences_service.dart';
import 'login_screen.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final data = await ref
          .read(userRepositoryProvider)
          .getUserProfile(userId);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Okul adı ve sınıf bilgisini birleştiren yardımcı metod
  String _buildSubtitle() {
    final schoolName = _userData?['schoolName'] as String?;
    // Firebase'de 'grade' veya 'classLevel' olarak kaydedilmiş olabilir
    final grade = (_userData?['grade'] ?? _userData?['classLevel']) as String?;

    final parts = <String>[];
    if (schoolName != null && schoolName.isNotEmpty) {
      parts.add(schoolName);
    }
    if (grade != null && grade.isNotEmpty) {
      // "3_Sinif" formatını "3. Sınıf" formatına çevir
      parts.add(_formatGrade(grade));
    }

    if (parts.isEmpty) {
      return 'Profil bilgisi bulunamadı';
    }

    return parts.join(' - ');
  }

  /// Sınıf formatını düzenler (örn: "3_Sinif" -> "3. Sınıf")
  String _formatGrade(String grade) {
    // Zaten doğru formattaysa direkt döndür
    if (grade.contains('. Sınıf')) {
      return grade;
    }

    // "3_Sinif" formatını "3. Sınıf" formatına çevir
    final match = RegExp(r'(\d+)_?[Ss]inif').firstMatch(grade);
    if (match != null) {
      return '${match.group(1)}. Sınıf';
    }

    return grade;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifrenizi Girin',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context); // Close dialog
                await _performAccountDeletion(passwordController.text);
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion(String password) async {
    try {
      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Delete Firestore data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // ✅ TÜM YEREL VERİLERİ TEMİZLE - Telefon yeni indirilmiş gibi olsun
        
        // 1. SQLite veritabanını temizle (dersler, konular, sorular, mascot vs.)
        final dbHelper = DatabaseHelper();
        await dbHelper.clearAllData();

        // 2. SharedPreferences cache'ini temizle (kullanıcı profili, ayarlar)
        final localPrefs = LocalPreferencesService();
        await localPrefs.clearAll();

        // 3. İndirilen içerik dosyalarını sil
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final contentDir = Directory('${appDir.path}/content');
          if (await contentDir.exists()) {
            await contentDir.delete(recursive: true);
          }
        } catch (e) {
          debugPrint('İçerik dosyaları silinemedi: $e');
        }

        // Delete Auth account
        await user.delete();

        if (mounted) {
          Navigator.pop(context); // Close loading

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hesabınız başarıyla silindi.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        String errorMessage = 'Bir hata oluştu.';
        if (e.code == 'wrong-password') {
          errorMessage = 'Şifre yanlış!';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil ve Ayarlar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _userData?['avatar'] != null
                        ? AssetImage(_userData!['avatar'])
                        : null,
                    child: _userData?['avatar'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _userData?['name'] ?? 'Kullanıcı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _buildSubtitle(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Genel'),
                  _buildSettingsItem(
                    context,
                    'Kullanıcı Sözleşmesi',
                    Icons.description,
                    () {
                      // Kullanıcı sözleşmesi gösterilecek
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    'Gizlilik Politikası',
                    Icons.privacy_tip,
                    () {
                      // Gizlilik politikası gösterilecek
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsItem(
                    context,
                    'Çıkış Yap',
                    Icons.logout,
                    _signOut,
                    color: Colors.orange,
                  ),
                  _buildSettingsItem(
                    context,
                    'Hesabı Sil',
                    Icons.delete_forever,
                    _deleteAccount,
                    color: Colors.red,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 16),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
