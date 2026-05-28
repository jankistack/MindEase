import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../mood_tracking/screens/mood_home_screen.dart';
import '../../meditation/screens/meditation_home_screen.dart';
//import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/mindease_drawer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const primaryColor = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@').first ?? 'User';
    final displayName = userName.isNotEmpty
        ? userName[0].toUpperCase() + userName.substring(1)
        : 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'MindEase',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MindEaseDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreetingSection(displayName),
              const SizedBox(height: 32),
              _buildQuickActionsRow(context),
              const SizedBox(height: 36),
              const Text(
                'Your Wellness Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildWellnessGrid(context),
              const SizedBox(height: 32),
              _buildDailyQuote(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 32,
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionButton(
          context,
          'Add Mood',
          Icons.add_reaction_rounded,
          const Color(0xFFFF9800),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MoodHomeScreen()),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          'Meditate',
          Icons.self_improvement_rounded,
          const Color(0xFF009688),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeditationHomeScreen()),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          'Journal',
          Icons.edit_note_rounded,
          const Color(0xFF2196F3),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Journal coming soon!')),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          'Breathe',
          Icons.air_rounded,
          const Color(0xFF9C27B0),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Breathing exercise coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildGridCard(
          title: "Today's Mood",
          value: 'Calm',
          subtitle: 'Updated 2h ago',
          icon: Icons.mood_rounded,
          color: Colors.orangeAccent,
          gradient: const [Color(0xFFFFA726), Color(0xFFFF7043)],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodHomeScreen()),
          ),
        ),
        _buildGridCard(
          title: 'Meditation',
          value: '15 Min',
          subtitle: 'Daily goal: 20m',
          icon: Icons.spa_rounded,
          color: Colors.teal,
          gradient: const [Color(0xFF26A69A), Color(0xFF00897B)],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MeditationHomeScreen()),
          ),
        ),
        _buildGridCard(
          title: 'Wellness Score',
          value: '85/100',
          subtitle: '+5 from yesterday',
          icon: Icons.monitor_heart_rounded,
          color: Colors.redAccent,
          gradient: const [Color(0xFFFF5252), Color(0xFFE53935)],
          onTap: () {},
        ),
        _buildGridCard(
          title: 'Journal Entries',
          value: '3 Days',
          subtitle: 'Current streak',
          icon: Icons.book_rounded,
          color: Colors.blueAccent,
          gradient: const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: primaryColor.withValues(alpha: 0.4),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            '"The mind is everything. What you think you become."',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '- Buddha',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
