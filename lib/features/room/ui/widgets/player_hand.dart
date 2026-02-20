import 'package:flutter/material.dart';
import 'letter_card.dart';

class PlayerHand extends StatelessWidget {
  final List<String> letters;
  final double? cardSize;
  final double? height;
  final double? gap;
  final double? radius;

  const PlayerHand({
    super.key,
    required this.letters,
    this.cardSize,
    this.height,
    this.gap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        separatorBuilder: (_, __) => SizedBox(width: gap ?? 8),
        itemBuilder: (context, index) {
          return LetterCard(
            letter: letters[index],
            size: cardSize ?? 56,
            radius: radius ?? 12,
            isElevated: false,
          );
        },
      ),
    );
  }
}
