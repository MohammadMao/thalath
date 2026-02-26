import 'package:flutter/material.dart';
import 'letter_card.dart';

class PlayerHand extends StatelessWidget {
  final List<String> letters;
  final double? cardSize;
  final double? height;
  final double? gap;
  final double? radius;
  final int? selectedIndex;
  final ValueChanged<int>? onCardTap;
  final bool isLost;

  const PlayerHand({
    super.key,
    required this.letters,
    this.cardSize,
    this.height,
    this.gap,
    this.radius,
    this.selectedIndex,
    this.onCardTap,
    this.isLost = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (height ?? 80) + 16, // extra space for selected card elevation
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        separatorBuilder: (_, __) => SizedBox(width: gap ?? 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final size = cardSize ?? 56;
          return GestureDetector(
            onTap: onCardTap != null ? () => onCardTap!(index) : null,
            child: SizedBox(
              width: size,
              height: size + 16,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    top: isSelected ? 0 : 16,
                    left: 0,
                    right: 0,
                    height: size + 16,
                    child: isLost
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: LetterCard(
                              letter: letters[index],
                              size: size,
                              radius: radius ?? 12,
                              isElevated: false,
                            ),
                          )
                        : LetterCard(
                            letter: letters[index],
                            size: size,
                            radius: radius ?? 12,
                            isElevated: isSelected,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
