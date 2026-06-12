import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    Future.microtask(() => loadMoods());
    return MoodState(moods: _localMoods, isLoading: true);
  }

  Future<void> loadMoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('mood_entries_$userId') ?? [];
      _localMoods.clear();
      for (final item in list) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final id = map['id'] as String;
        _localMoods.add(MoodEntry.fromMap(map, id));
      }
      _localMoods.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = MoodState(moods: List.from(_localMoods), isLoading: false);
    } catch (e) {
      debugPrint('Error loading moods from storage: $e');
      state = MoodState(moods: List.from(_localMoods), isLoading: false, error: e.toString());
    }
  }

  Future<void> _saveMoodsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _localMoods.map((e) => jsonEncode({
        'id': e.id,
        'moodScore': e.moodScore,
        'emoji': e.emoji,
        'note': e.note,
        'timestamp': e.timestamp.toIso8601String(),
      })).toList();
      await prefs.setStringList('mood_entries_$userId', list);
    } catch (e) {
      debugPrint('Error saving moods to storage: $e');
    }
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
      await _saveMoodsToStorage();
      state = MoodState(moods: List.from(_localMoods), isLoading: false);
    } catch (e) {
      debugPrint('Error adding mood: $e');
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      _localMoods.removeWhere((element) => element.id == id);
      await _saveMoodsToStorage();
      state = MoodState(moods: List.from(_localMoods), isLoading: false);
    } catch (e) {
      debugPrint('Error deleting mood: $e');
    }
  }
}

final moodProvider = NotifierProvider<MoodNotifier, MoodState>(() {
  return MoodNotifier();
});
