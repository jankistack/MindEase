import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import 'mood_entry_screen.dart';
import 'mood_analytics_screen.dart';
import '../../../shared/widgets/mindease_drawer.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class MoodHomeScreen extends ConsumerWidget {
  const MoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mood Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodAnalyticsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MindEaseDrawer(),
      body: Builder(
        builder: (context) {
          if (moodState.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: AppShimmerList(itemCount: 4, itemHeight: 120.0),
            );
          }
          if (moodState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${moodState.error}', style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            );
          }
          
          final moods = moodState.moods;
          if (moods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mood_bad_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'No moods logged yet.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodEntryScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('Log First Mood'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: moods.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Score: ${mood.moodScore}/5',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(mood.timestamp),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (mood.note.isNotEmpty)
                                Text(
                                  mood.note,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                                )
                              else
                                Text(
                                  'No notes provided.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[400], fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () {
                            ref.read(moodProvider.notifier).deleteMoodEntry(mood.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: moodState.moods.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodEntryScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_reaction_rounded),
        label: const Text('Log Mood'),
      ) : null,
    );
  }
}
