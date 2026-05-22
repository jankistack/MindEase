class MoodEntry {
  final String id;
  final int moodScore; 
  final String emoji;
  final String note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.moodScore,
    required this.emoji,
    required this.note,
    required this.timestamp,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      id: id,
      moodScore: map['moodScore'] ?? 3,
      emoji: map['emoji'] ?? '😐',
      note: map['note'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moodScore': moodScore,
      'emoji': emoji,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
