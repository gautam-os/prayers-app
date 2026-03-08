import 'package:flutter/material.dart';
import '../data/prayers.dart';
import '../models/japa_session.dart';
import '../models/prayer.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = StorageService.getAllSessions();

    if (sessions.isEmpty) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded,
                  size: 64, color: AppColors.saffron.withAlpha(100)),
              const SizedBox(height: 16),
              Text(
                'No sessions yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.subtleText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a prayer to see your history here',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _groupByDate(sessions);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('History', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _prayerStatsSection(context),
                  const SizedBox(height: 20),
                  ...grouped.map((entry) =>
                      _dateGroup(context, entry.label, entry.sessions)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: allPrayers.map((prayer) {
          final count = StorageService.totalCountForPrayer(prayer.id);
          final minutes = StorageService.totalMinutesForPrayer(prayer.id);
          final lastPracticed = StorageService.lastPracticedForPrayer(prayer.id);

          return _prayerStatRow(context, prayer, count, minutes, lastPracticed);
        }).toList(),
      ),
    );
  }

  Widget _prayerStatRow(BuildContext context, Prayer prayer, int count,
      int minutes, DateTime? lastPracticed) {
    String lastStr = 'Never';
    if (lastPracticed != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final practiceDay = DateTime(
          lastPracticed.year, lastPracticed.month, lastPracticed.day);
      final diff = today.difference(practiceDay).inDays;
      if (diff == 0) {
        lastStr = 'Today';
      } else if (diff == 1) {
        lastStr = 'Yesterday';
      } else {
        lastStr = '${diff}d ago';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              prayer.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _miniStat(_formatNumber(count), 'count'),
                _miniStat('${minutes}m', 'time'),
                _miniStat(lastStr, 'last'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(160),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _dateGroup(
      BuildContext context, String label, List<JapaSession> sessions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtleText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...sessions.map((s) => _sessionRow(context, s)),
        ],
      ),
    );
  }

  Widget _sessionRow(BuildContext context, JapaSession session) {
    final prayer = allPrayers.firstWhere((p) => p.id == session.prayerId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightSaffron),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            '\u00d7${session.count}',
            style: const TextStyle(
              color: AppColors.deepOrange,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            session.formattedDuration,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }

  List<_DateGroup> _groupByDate(List<JapaSession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<JapaSession>>{};
    final groupOrder = <String>[];

    for (final s in sessions) {
      final d = DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day);
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        label = '${months[d.month - 1]} ${d.day}';
      }
      if (!groups.containsKey(label)) {
        groups[label] = [];
        groupOrder.add(label);
      }
      groups[label]!.add(s);
    }

    return groupOrder
        .map((label) => _DateGroup(label: label, sessions: groups[label]!))
        .toList();
  }
}

class _DateGroup {
  final String label;
  final List<JapaSession> sessions;
  const _DateGroup({required this.label, required this.sessions});
}
