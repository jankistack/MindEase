import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/mood_tracking/screens/mood_home_screen.dart';
import '../../features/meditation/screens/meditation_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';

class MindEaseDrawer extends ConsumerWidget {
  const MindEaseDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Home / Dashboard',
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.mood_rounded,
                    title: 'Mood Tracker',
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const MoodHomeScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.self_improvement_rounded,
                    title: 'Meditation',
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const MeditationHomeScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_rounded,
                    title: 'Analytics & Trends',
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.book_rounded,
                    title: 'Journal',
                    onTap: () => _showComingSoon(context, 'Journal'),
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: () => _showComingSoon(context, 'Settings'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              color: Colors.redAccent,
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        gradient: const LinearGradient(
          colors: [
             Color(0xFF6A1B9A),
             Color(0xFF8E24AA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Text(
              user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'M',
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindEase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Wellness App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.grey[800],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
