class MeditationSession {
  final String id;
  final String title;
  final String category; // e.g., Stress, Sleep, Anxiety, Focus
  final int durationMinutes;
  final String? audioUrl; // Local or remote url, optional

  MeditationSession({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.audioUrl,
  });
}

final List<MeditationSession> sampleSessions = [
  MeditationSession(id: '1', title: 'Deep Sleep Breathing', category: 'Sleep', durationMinutes: 5),
  MeditationSession(id: '2', title: 'Morning Focus', category: 'Focus', durationMinutes: 10),
  MeditationSession(id: '3', title: 'Anxiety Relief', category: 'Anxiety', durationMinutes: 3),
  MeditationSession(id: '4', title: 'Quick Stress Reset', category: 'Stress', durationMinutes: 5),
];
