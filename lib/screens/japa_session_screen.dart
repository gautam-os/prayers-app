import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer.dart';
import '../models/japa_session.dart';
import '../services/haptic_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'session_complete_screen.dart';

class JapaSessionScreen extends StatefulWidget {
  final Prayer prayer;
  final int targetCount;
  final bool showEnglish;

  const JapaSessionScreen({
    super.key,
    required this.prayer,
    required this.targetCount,
    required this.showEnglish,
  });

  @override
  State<JapaSessionScreen> createState() => _JapaSessionScreenState();
}

class _JapaSessionScreenState extends State<JapaSessionScreen> {
  int _count = 0;
  late bool _showEnglish;
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _showEnglish = widget.showEnglish;
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _increment() {
    HapticService.tap();
    setState(() => _count++);
    if (_count >= widget.targetCount) {
      _completeSession();
    }
  }

  void _completeSession() async {
    _stopwatch.stop();
    _timer.cancel();
    HapticService.complete();

    final session = JapaSession(
      prayerId: widget.prayer.id,
      count: _count,
      durationSeconds: _stopwatch.elapsed.inSeconds,
      completedAt: DateTime.now(),
    );
    await StorageService.saveSession(session);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCompleteScreen(
          prayer: widget.prayer,
          session: session,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text =
        _showEnglish ? widget.prayer.englishText : widget.prayer.originalText;
    final elapsed = _stopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: GestureDetector(
        onTap: _increment,
        onLongPress: () {
          if (_count > 0) _completeSession();
        },
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradient),
          child: SafeArea(
            child: Column(
              children: [
                if (widget.prayer.hasTranslation)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_languageToggle()],
                    ),
                  ),
                const Spacer(),
                Text(
                  widget.prayer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 18,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_count / ${widget.targetCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: $minutes:$seconds',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap anywhere to count',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Long-press to finish',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn('Original', !_showEnglish),
          _toggleBtn('English', _showEnglish),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _showEnglish = label == 'English');
        StorageService.setShowEnglish(widget.prayer.id, _showEnglish);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.deepOrange : Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
