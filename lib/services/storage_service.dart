import 'package:hive_flutter/hive_flutter.dart';
import '../models/japa_session.dart';

class StorageService {
  static const _sessionsBox = 'sessions';
  static const _prefsBox = 'preferences';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_sessionsBox);
    await Hive.openBox(_prefsBox);
  }

  // --- Sessions ---

  static List<JapaSession> getAllSessions() {
    final box = Hive.box(_sessionsBox);
    final sessions = <JapaSession>[];
    for (var i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw != null) {
        sessions.add(JapaSession.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  static Future<void> saveSession(JapaSession session) async {
    final box = Hive.box(_sessionsBox);
    await box.add(session.toMap());
  }

  static int totalCountForPrayer(String prayerId) {
    return getAllSessions()
        .where((s) => s.prayerId == prayerId)
        .fold(0, (sum, s) => sum + s.count);
  }

  static int totalCount() {
    return getAllSessions().fold(0, (sum, s) => sum + s.count);
  }

  static int totalMinutes() {
    final totalSeconds =
        getAllSessions().fold(0, (sum, s) => sum + s.durationSeconds);
    return (totalSeconds / 60).round();
  }

  static int currentStreak() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sessionDays = sessions
        .map((s) =>
            DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sessionDays.isEmpty) return 0;

    final mostRecent = sessionDays.first;
    final diff = today.difference(mostRecent).inDays;
    if (diff > 1) return 0;

    int streak = 1;
    for (var i = 1; i < sessionDays.length; i++) {
      final gap = sessionDays[i - 1].difference(sessionDays[i]).inDays;
      if (gap == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }


  static int totalMinutesForPrayer(String prayerId) {
    final totalSeconds = getAllSessions()
        .where((s) => s.prayerId == prayerId)
        .fold(0, (sum, s) => sum + s.durationSeconds);
    return (totalSeconds / 60).round();
  }

  static DateTime? lastPracticedForPrayer(String prayerId) {
    final sessions = getAllSessions()
        .where((s) => s.prayerId == prayerId)
        .toList();
    if (sessions.isEmpty) return null;
    return sessions.first.completedAt;
  }
  // --- Preferences ---

  static int? getLastCount(String prayerId) {
    final box = Hive.box(_prefsBox);
    return box.get('lastCount_$prayerId') as int?;
  }

  static Future<void> setLastCount(String prayerId, int count) async {
    final box = Hive.box(_prefsBox);
    await box.put('lastCount_$prayerId', count);
  }

  static bool getShowEnglish(String prayerId) {
    final box = Hive.box(_prefsBox);
    return box.get('showEnglish_$prayerId', defaultValue: false) as bool;
  }

  static Future<void> setShowEnglish(String prayerId, bool value) async {
    final box = Hive.box(_prefsBox);
    await box.put('showEnglish_$prayerId', value);
  }
}
