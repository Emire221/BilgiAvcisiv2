import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../services/local_preferences_service.dart';
import 'content_loading_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

/// Professional & Lightweight Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Background Colors - Professional Dark Theme
  static const Color _backgroundBase = Color(0xFF0D1B2A); // Deep Navy/Black
  static const Color _accentColor = Color(0xFF6C5CE7); // Soft Purple glow

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Splash animasyonu için bekle
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // Kullanıcı durumunu kontrol et ve yönlendir
    await _checkAuthAndNavigate();
  }

  /// Kullanıcı durumunu kontrol eder ve uygun ekrana yönlendirir
  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;

    // 📌 DURUM 1: Kullanıcı giriş yapmamış
    if (user == null) {
      _navigateToScreen(const LoginScreen());
      return;
    }

    // 📌 DURUM 2: Kullanıcı giriş yapmış - profil kontrolü
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Profil yoksa → ProfileSetupScreen
      if (!userDoc.exists) {
        _navigateToScreen(const ProfileSetupScreen());
        return;
      }

      // 📌 DURUM 3: Profil var - içerik senkronizasyon kontrolü
      final prefsService = LocalPreferencesService();
      final isContentSynced = await prefsService.isContentSyncCompleted();

      if (isContentSynced) {
        // ✅ İçerik başarıyla indirilmiş → MainScreen
        _navigateToScreen(const MainScreen());
      } else {
        // ❌ İçerik indirilmemiş veya yarım kalmış → ContentLoadingScreen
        _navigateToScreen(const ContentLoadingScreen());
      }
    } catch (e) {
      // Hata durumunda güvenli tarafta kal - ContentLoadingScreen
      debugPrint('Auth kontrol hatası: $e');
      _navigateToScreen(const ContentLoadingScreen());
    }
  }

  /// Belirtilen ekrana fade geçişi ile yönlendirir
  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _backgroundBase,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Background (Static, extremely lightweight)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF15202B), // Slightly lighter at bottom
                  ],
                ),
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // 1. Large Logo (Prominent & Eye-catching)
                  // "Logo ekranda ilk göze çarpan yer olsun diğer öğelere göre büyük olsun"
                  Container(
                        width: screenWidth * 0.5, // 50% of screen width
                        height: screenWidth * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _accentColor.withValues(alpha: 0.15),
                              blurRadius: 60,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/appicon/splash_logo.png',
                          fit: BoxFit.contain,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 1000.ms,
                        curve: Curves.elasticOut,
                      ),

                  const Spacer(flex: 2),

                  // 2. Astronaut Animation (Secondary element)
                  // "sadece Astronot animasyonu"
                  SizedBox(
                        height: screenHeight * 0.2, // Smaller than logo
                        child: Lottie.asset(
                          'assets/animation/astronot_mascot.json',
                          fit: BoxFit.contain,
                          // Ensure it doesn't loop infinitely if distraction is a concern,
                          // but usually mascots loop. Let's keep it looping.
                        ),
                      )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutQuad,
                      ),

                  const Spacer(flex: 3),

                  // Optional: Very subtle version info or loader if needed
                  // Keeping it minimal as requested "sade"
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
