import 'package:flutter/material.dart';
import '../models/prayer.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'japa_session_screen.dart';
import 'teleprompter_session_screen.dart';

class CountPickerScreen extends StatefulWidget {
  final Prayer prayer;

  const CountPickerScreen({super.key, required this.prayer});

  @override
  State<CountPickerScreen> createState() => _CountPickerScreenState();
}

class _CountPickerScreenState extends State<CountPickerScreen> {
  late int _selectedCount;
  late bool _showEnglish;

  @override
  void initState() {
    super.initState();
    final lastCount = StorageService.getLastCount(widget.prayer.id);
    _selectedCount = lastCount ?? widget.prayer.presetCounts[widget.prayer.presetCounts.length ~/ 2];
    _showEnglish = widget.prayer.hasTranslation
        ? StorageService.getShowEnglish(widget.prayer.id)
        : false;
  }

  @override
  Widget build(BuildContext context) {
    final text =
        _showEnglish ? widget.prayer.englishText : widget.prayer.originalText;

    return Scaffold(
      backgroundColor: AppColors.deepOrange,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        widget.prayer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (widget.prayer.hasTranslation) _languageToggle(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: 16,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'How many times?',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _countPicker(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showCustomCountDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white.withAlpha(100), width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+ Custom',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startPrayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 4,
                            shadowColor: Colors.black.withAlpha(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Start Prayer',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
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
          _toggleButton('Original', !_showEnglish),
          _toggleButton('English', _showEnglish),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _showEnglish = label == 'English');
        StorageService.setShowEnglish(widget.prayer.id, _showEnglish);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.deepOrange : Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _countPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.prayer.presetCounts.map((count) {
        final isSelected = count == _selectedCount;
        return GestureDetector(
          onTap: () => setState(() => _selectedCount = count),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: isSelected ? 76 : 68,
            height: isSelected ? 76 : 68,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(isSelected ? 22 : 18),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withAlpha(80),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? AppColors.deepOrange : Colors.white,
                  fontSize: isSelected ? 26 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCustomCountDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Count'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Enter number of repetitions'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _selectedCount = val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startPrayer() async {
    await StorageService.setLastCount(widget.prayer.id, _selectedCount);

    if (!mounted) return;

    if (widget.prayer.isTeleprompter) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeleprompterSessionScreen(
            prayer: widget.prayer,
            targetCount: _selectedCount,
            showEnglish: _showEnglish,
          ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JapaSessionScreen(
            prayer: widget.prayer,
            targetCount: _selectedCount,
            showEnglish: _showEnglish,
          ),
        ),
      );
    }

  }
}
