import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class GameResultDialog extends StatelessWidget {
  final bool isWinner;
  final bool isCreator;
  final String winnerName; // Single or multiple winners joined by ' و '
  final VoidCallback? onReplay; // creator only
  final VoidCallback? onStay;  // non-creator only
  final VoidCallback onQuit;

  const GameResultDialog({
    super.key,
    required this.isWinner,
    required this.isCreator,
    required this.winnerName,
    this.onReplay,
    this.onStay,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isWinner ? AppTheme.primaryGreen : Colors.redAccent;

    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy / sad icon
            Icon(
              isWinner
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              size: 72,
              color: isWinner ? Colors.amber : Colors.redAccent,
            ),
            const SizedBox(height: 16),
            // Result text
            Text(
              isWinner ? 'مبروك! 🎉' : 'خسرت',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Winner name with trophy
            Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 24,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'الفائز: ${winnerName.isNotEmpty ? winnerName : 'لاعب'}',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action buttons
            if (isCreator) ...[
              _fullButton(
                label: 'إعادة اللعبة',
                onPressed: onReplay,
                filled: true,
                color: AppTheme.primaryTeal,
                context: context,
              ),
              const SizedBox(height: 12),
              _fullButton(
                label: 'خروج',
                onPressed: onQuit,
                filled: false,
                color: Colors.redAccent,
                context: context,
              ),
            ] else ...[
              _fullButton(
                label: 'انتظار',
                onPressed: onStay,
                filled: true,
                color: AppTheme.primaryTeal,
                context: context,
              ),
              const SizedBox(height: 12),
              _fullButton(
                label: 'خروج',
                onPressed: onQuit,
                filled: false,
                color: Colors.redAccent,
                context: context,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fullButton({
    required String label,
    required VoidCallback? onPressed,
    required bool filled,
    required Color color,
    required BuildContext context,
  }) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    if (filled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: shape,
          ),
          child: Text(label, style: textStyle),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: shape,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}
