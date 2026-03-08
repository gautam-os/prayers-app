import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/prayer.dart';
import '../models/japa_session.dart';
import '../services/haptic_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'session_complete_screen.dart';

class TeleprompterSessionScreen extends StatefulWidget {
  final Prayer prayer;
  final int targetCount;
  final bool showEnglish;

  const TeleprompterSessionScreen({
    super.key,
    required this.prayer,
    required this.targetCount,
    required this.showEnglish,
  });

  @override
  State<TeleprompterSessionScreen> createState() =>
      _TeleprompterSessionScreenState();
}

class _TeleprompterSessionScreenState extends State<TeleprompterSessionScreen>
    with SingleTickerProviderStateMixin {
  int _currentVerse = 0;
  int _count = 0;
  late bool _showEnglish;
  late Stopwatch _stopwatch;
  late Timer _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<String> get _verses =>
      _showEnglish ? widget.prayer.englishVerses : widget.prayer.originalVerses;

  @override
  void initState() {
    super.initState();
    _showEnglish = widget.showEnglish;
    _stopwatch = Stopwatch()..start();
    WakelockPlus.enable();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _fadeController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _advanceVerse() async {
    HapticService.tap();
    await _fadeController.forward();

    setState(() {
      if (_currentVerse < _verses.length - 1) {
        _currentVerse++;
      } else {
        _count++;
        if (_count >= widget.targetCount) {
          _completeSession();
          return;
        }
        _currentVerse = 0;
      }
    });

    _fadeController.reverse();
  }

  void _previousVerse() async {
    if (_currentVerse > 0) {
      HapticService.tap();
      await _fadeController.forward();
      setState(() => _currentVerse--);
      _fadeController.reverse();
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

  Future<void> _confirmFinish() async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish session?'),
        content: Text(
          'You have completed $_count of ${widget.targetCount} rounds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (shouldFinish == true && mounted) {
      _completeSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final verses = _verses;
    final screenHeight = MediaQuery.of(context).size.height;
    final verseFontSize = screenHeight * 0.028;

    return Scaffold(
      backgroundColor: AppColors.deepOrange,
      body: GestureDetector(
        onTap: _advanceVerse,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -100) {
              _advanceVerse();
            } else if (details.primaryVelocity! > 100) {
              _previousVerse();
            }
          }
        },
        onLongPress: () {
          if (_count > 0) {
            _confirmFinish();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  label: widget.prayer.title,
                  child: Text(
                    widget.prayer.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.032,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Semantics(
                      label: 'Verse ${_currentVerse + 1} of ${verses.length}',
                      child: Text(
                        _currentVerse < verses.length
                            ? verses[_currentVerse]
                            : '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: verseFontSize.clamp(18.0, 28.0),
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Current verse ${_currentVerse + 1} of ${verses.length}',
                      child: Text(
                        'Verse ${_currentVerse + 1} of ${verses.length}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Semantics(
                      label: 'Completed rounds $_count of ${widget.targetCount}',
                      child: Text(
                        '$_count / ${widget.targetCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: $minutes:$seconds',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tap or swipe to advance',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Long-press to finish',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
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
        setState(() {
          _showEnglish = label == 'English';
          _currentVerse = 0;
        });
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
