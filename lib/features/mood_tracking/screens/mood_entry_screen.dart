import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';

class MoodEntryScreen extends ConsumerStatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  ConsumerState<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends ConsumerState<MoodEntryScreen> {
  int _selectedScore = 3;
  String _selectedEmoji = '😐';
  final _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moodOptionList = [
    {'score': 1, 'emoji': '😢', 'label': 'Awful'},
    {'score': 2, 'emoji': '😟', 'label': 'Bad'},
    {'score': 3, 'emoji': '😐', 'label': 'Okay'},
    {'score': 4, 'emoji': '🙂', 'label': 'Good'},
    {'score': 5, 'emoji': '😁', 'label': 'Great'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Your Mood')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('How are you feeling?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _moodOptionList.map((mood) {
                final isSelected = _selectedScore == mood['score'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedScore = mood['score'];
                      _selectedEmoji = mood['emoji'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(mood['label'], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(moodProvider.notifier).addMoodEntry(_selectedScore, _selectedEmoji, _noteController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Save Entry', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
