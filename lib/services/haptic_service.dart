import 'package:flutter/services.dart';

class HapticService {
  static void tap() {
    HapticFeedback.lightImpact();
  }

  static void complete() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.heavyImpact();
    });
  }
}
