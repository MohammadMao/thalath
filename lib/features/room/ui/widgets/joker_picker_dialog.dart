import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/game_engine/game_engine.dart';
import 'letter_card.dart';

/// Compact popup that lets a player choose a letter to use in place of '?'.
class JokerPickerDialog extends StatelessWidget {
  const JokerPickerDialog({super.key});

  /// Shows the picker and returns the chosen letter, or null if cancelled.
  static Future<String?> show() {
    return Get.dialog<String>(
      const JokerPickerDialog(),
      barrierDismissible: true, // tap outside = cancel
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = GameEngine.letterPool.where((l) => l != '?').toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر الحرف البديل',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              const Text(
                'سيحل محل بطاقة الجوكر',
                style: TextStyle(fontSize: 13, color: Colors.white54),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final letter in letters)
                    GestureDetector(
                      onTap: () => Get.back(result: letter),
                      child: LetterCard(
                        letter: letter,
                        size: 44,
                        radius: 10,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: null),
                  child: const Text('إلغاء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
