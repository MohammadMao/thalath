import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'letter_card.dart';

class WordCards extends StatelessWidget {
  final List<String> letters;

  const WordCards({
    super.key,
    required this.letters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < letters.length; i++) ...[
          LetterCard(
            letter: letters[i],
            size: 90.w,
            radius: 16.r,
          ),
          if (i != letters.length - 1) SizedBox(width: 12.w),
        ],
      ],
    );
  }
}
