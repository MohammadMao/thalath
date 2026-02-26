import 'package:flutter/material.dart';
import 'letter_card.dart';

class WordCards extends StatelessWidget {
  final List<String> letters;
  final double? cardSize;
  final double? gap;
  final double? radius;
  final bool rtl;
  final ValueChanged<int>? onCardTap;
  final Color? flashColor;

  const WordCards({
    super.key,
    required this.letters,
    this.cardSize,
    this.gap,
    this.radius,
    this.rtl = true,
    this.onCardTap,
    this.flashColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayLetters = letters;
    final size = cardSize ?? 90;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(flashColor != null ? 8 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular((radius ?? 16) + 8),
        boxShadow: flashColor != null
            ? [
                BoxShadow(
                  color: flashColor!.withValues(alpha: 0.7),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: flashColor!.withValues(alpha: 0.4),
                  blurRadius: 64,
                  spreadRadius: 16,
                ),
              ]
            : null,
      ),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < displayLetters.length; i++) ...[
              GestureDetector(
                onTap: onCardTap != null ? () => onCardTap!(i) : null,
                child: LetterCard(
                  letter: displayLetters[i],
                  size: size,
                  radius: radius ?? 16,
                ),
              ),
              if (i != displayLetters.length - 1) SizedBox(width: gap ?? 12),
            ],
          ],
        ),
      ),
    );
  }
}
