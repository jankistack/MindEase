import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meditation_session.dart';
import '../providers/meditation_provider.dart';
import 'meditation_player_screen.dart';
import '../../../shared/widgets/mindease_drawer.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class MeditationHomeScreen extends ConsumerWidget {
  const MeditationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(meditationProgressProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Guided Meditation', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      drawer: const MindEaseDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('Total Mindful Minutes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 12),
                progress.isLoading
                    ? const AppShimmer(width: 80, height: 60, borderRadius: 16)
                    : Text('${progress.totalMinutes}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.teal, height: 1.0)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft, 
              child: Text(
                'Recommended Sessions', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: sampleSessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final session = sampleSessions[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.self_improvement_rounded, color: Colors.teal, size: 28),
                    ),
                    title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${session.category} • ${session.durationMinutes} min', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationPlayerScreen(session: session)));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
