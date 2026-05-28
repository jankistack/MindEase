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
    {'score': 1, 'emoji': '😢', 'label': 'Awful', 'color': Colors.redAccent},
    {'score': 2, 'emoji': '😟', 'label': 'Bad', 'color': Colors.orangeAccent},
    {'score': 3, 'emoji': '😐', 'label': 'Okay', 'color': Colors.amber},
    {'score': 4, 'emoji': '🙂', 'label': 'Good', 'color': Colors.lightGreen},
    {'score': 5, 'emoji': '😁', 'label': 'Great', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Log Your Mood', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'How are you feeling right now?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moodOptionList.map((mood) {
                final isSelected = _selectedScore == mood['score'];
                final color = mood['color'] as Color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedScore = mood['score'];
                      _selectedEmoji = mood['emoji'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: isSelected ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))
                      ] : [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood['emoji'],
                          style: TextStyle(fontSize: isSelected ? 36 : 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color.withValues(alpha: 0.9) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What\'s making you feel this way? (optional)',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(moodProvider.notifier).addMoodEntry(_selectedScore, _selectedEmoji, _noteController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
