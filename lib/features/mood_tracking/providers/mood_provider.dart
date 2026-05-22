import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

class MoodState {
  final List<MoodEntry> moods;
  final bool isLoading;
  final String? error;

  MoodState({required this.moods, required this.isLoading, this.error});
}

class MoodNotifier extends Notifier<MoodState> {
  final List<MoodEntry> _localMoods = [];
  
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

  @override
  MoodState build() {
    return MoodState(moods: _localMoods, isLoading: false);
  }

  Future<void> addMoodEntry(int score, String emoji, String note) async {
    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        moodScore: score,
        emoji: emoji,
        note: note,
        timestamp: DateTime.now(),
      );
      _localMoods.insert(0, entry);
      state = MoodState(moods: List.from(_localMoods), isLoading: false);
    } catch (e) {
      debugPrint('Error adding mood locally: $e');
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      _localMoods.removeWhere((element) => element.id == id);
      state = MoodState(moods: List.from(_localMoods), isLoading: false);
    } catch (e) {
      debugPrint('Error deleting mood locally: $e');
    }
  }
}

final moodProvider = NotifierProvider<MoodNotifier, MoodState>(() {
  return MoodNotifier();
});
