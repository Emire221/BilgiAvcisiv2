import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

/// Bildirimler Widget - Neon Notification Teması
class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  // Neon Notification Teması Renkleri
  static const Color _primaryPurple = Color(0xFF9C27B0);
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _dbHelper.getNotifications();
    });
  }

  Future<void> _deleteNotification(int id, int index) async {
    await _dbHelper.deleteNotification(id);
    _loadNotifications();
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Az önce';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} dakika önce';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} saat önce';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else {
        return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
      }
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      width: isTablet ? 500 : double.infinity,
      height: size.height * 0.52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepPurple, _darkBg],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _accentCyan.withValues(alpha: 0.3), width: 1),
          left: BorderSide(color: _accentCyan.withValues(alpha: 0.3), width: 1),
          right: BorderSide(color: _accentCyan.withValues(alpha: 0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🔔',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'BİLDİRİMLER',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Bildirim listesi
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: _accentCyan,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.circleExclamation,
                              color: Colors.red.withValues(alpha: 0.7),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hata oluştu',
                              style: GoogleFonts.nunito(
                                color: Colors.red.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final notifications = snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FontAwesomeIcons.bellSlash,
                                size: 40,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz bildirim yok',
                              style: GoogleFonts.nunito(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final int id = notification['id'] as int;
                        final String title = notification['title'] as String;
                        final String body = notification['body'] as String;
                        final String date = notification['date'] as String;
                        final bool isRead =
                            (notification['isRead'] as int) == 1;

                        return _buildNotificationItem(
                              id: id,
                              title: title,
                              body: body,
                              date: date,
                              isRead: isRead,
                              index: index,
                            )
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: index < 10 ? 50 * index : 0))
                            .slideX(begin: 0.1, end: 0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required int id,
    required String title,
    required String body,
    required String date,
    required bool isRead,
    required int index,
  }) {
    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.3),
              Colors.red.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          FontAwesomeIcons.trash,
          color: Colors.white,
          size: 18,
        ),
      ),
      onDismissed: (direction) async {
        HapticFeedback.mediumImpact();
        await _deleteNotification(id, index);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title silindi', style: GoogleFonts.nunito()),
              backgroundColor: _deepPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          if (!isRead) {
            await _dbHelper.markNotificationAsRead(id);
            _loadNotifications();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white.withValues(alpha: 0.03)
                : _accentCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? Colors.white.withValues(alpha: 0.05)
                  : _accentCyan.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.white.withValues(alpha: 0.05)
                      : _accentCyan.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: isRead
                      ? null
                      : [
                          BoxShadow(
                            color: _accentCyan.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Icon(
                  FontAwesomeIcons.solidBell,
                  color: isRead
                      ? Colors.white.withValues(alpha: 0.3)
                      : _accentCyan,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 14,
                        color: isRead
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(date),
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Okunmamış göstergesi
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _accentCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accentCyan.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
