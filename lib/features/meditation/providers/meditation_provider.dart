import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return MeditationState(totalMinutes: _localTotalMinutes, isLoading: false);
  }

  Future<void> logSessionCompletion(int minutes) async {
    try {
      _localTotalMinutes += minutes;
      state = MeditationState(totalMinutes: _localTotalMinutes, isLoading: false);
    } catch (e) {
      debugPrint('Error logging meditation session locally: $e');
    }
  }
}

final meditationProgressProvider = NotifierProvider<MeditationProgressNotifier, MeditationState>(() {
  return MeditationProgressNotifier();
});
