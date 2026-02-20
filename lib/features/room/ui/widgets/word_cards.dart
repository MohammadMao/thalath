import 'package:flutter/material.dart';
import 'letter_card.dart';

class WordCards extends StatelessWidget {
  final List<String> letters;
  final double? cardSize;
  final double? gap;
  final double? radius;

  const WordCards({
    super.key,
    required this.letters,
    this.cardSize,
    this.gap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < letters.length; i++) ...[
          LetterCard(
            letter: letters[i],
            size: cardSize ?? 90,
            radius: radius ?? 16,
          ),
          if (i != letters.length - 1) SizedBox(width: gap ?? 12),
        ],
      ],
    );
  }
}
