import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import 'mood_entry_screen.dart';
import 'mood_analytics_screen.dart';

class MoodHomeScreen extends ConsumerWidget {
  const MoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodAnalyticsScreen())),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (moodState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (moodState.error != null) {
            return Center(child: Text('Error: ${moodState.error}'));
          }
          
          final moods = moodState.moods;
          if (moods.isEmpty) {
            return const Center(child: Text('No mood entries yet. Add one!'));
          }
          
          return ListView.builder(
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return ListTile(
                leading: Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                title: Text('Mood Score: ${mood.moodScore}/5'),
                subtitle: Text('${DateFormat('MMM d, yyyy - h:mm a').format(mood.timestamp)}\n${mood.note}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    ref.read(moodProvider.notifier).deleteMoodEntry(mood.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodEntryScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
