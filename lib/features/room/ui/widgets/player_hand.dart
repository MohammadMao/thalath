import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'letter_card.dart';

class PlayerHand extends StatelessWidget {
  final List<String> letters;

  const PlayerHand({
    super.key,
    required this.letters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return LetterCard(
            letter: letters[index],
            size: 56.w,
            radius: 12.r,
            isElevated: false,
          );
        },
      ),
    );
  }
}
