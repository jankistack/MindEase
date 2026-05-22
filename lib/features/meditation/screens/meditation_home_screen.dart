import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meditation_session.dart';
import '../providers/meditation_provider.dart';
import 'meditation_player_screen.dart';

class MeditationHomeScreen extends ConsumerWidget {
  const MeditationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(meditationProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Guided Meditation')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Column(
              children: [
                const Text('Total Mindful Minutes', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                progress.isLoading
                    ? const CircularProgressIndicator()
                    : Text('${progress.totalMinutes}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text('Recommended Sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sampleSessions.length,
              itemBuilder: (context, index) {
                final session = sampleSessions[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.self_improvement, color: Colors.white),
                  ),
                  title: Text(session.title),
                  subtitle: Text('${session.category} • ${session.durationMinutes} min'),
                  trailing: const Icon(Icons.play_circle_fill, color: Colors.teal),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationPlayerScreen(session: session)));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
