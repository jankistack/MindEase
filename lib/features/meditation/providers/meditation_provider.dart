import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeditationState {
  final int totalMinutes;
  final bool isLoading;

  MeditationState({required this.totalMinutes, required this.isLoading});
}

class MeditationProgressNotifier extends Notifier<MeditationState> {
  int _localTotalMinutes = 0;
  
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

  @override
  MeditationState build() {
    Future.microtask(() => loadMeditationProgress());
    return MeditationState(totalMinutes: _localTotalMinutes, isLoading: true);
  }

  Future<void> loadMeditationProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _localTotalMinutes = prefs.getInt('meditation_minutes_$userId') ?? 0;
      state = MeditationState(totalMinutes: _localTotalMinutes, isLoading: false);
    } catch (e) {
      debugPrint('Error loading meditation progress: $e');
      state = MeditationState(totalMinutes: _localTotalMinutes, isLoading: false);
    }
  }

  Future<void> logSessionCompletion(int minutes) async {
    try {
      _localTotalMinutes += minutes;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('meditation_minutes_$userId', _localTotalMinutes);
      state = MeditationState(totalMinutes: _localTotalMinutes, isLoading: false);
    } catch (e) {
      debugPrint('Error logging meditation session: $e');
    }
  }
}

final meditationProgressProvider = NotifierProvider<MeditationProgressNotifier, MeditationState>(() {
  return MeditationProgressNotifier();
});
