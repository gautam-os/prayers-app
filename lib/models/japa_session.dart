class JapaSession {
  final String prayerId;
  final int count;
  final int durationSeconds;
  final DateTime completedAt;

  const JapaSession({
    required this.prayerId,
    required this.count,
    required this.durationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'prayerId': prayerId,
        'count': count,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
      };

  factory JapaSession.fromMap(Map<dynamic, dynamic> map) => JapaSession(
        prayerId: map['prayerId'] as String,
        count: map['count'] as int,
        durationSeconds: map['durationSeconds'] as int,
        completedAt: DateTime.parse(map['completedAt'] as String),
      );

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }
}
