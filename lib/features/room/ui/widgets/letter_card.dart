import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/letter_colors.dart';

class LetterCard extends StatelessWidget {
  final String letter;
  final double size;
  final double radius;
  final bool isElevated;

  const LetterCard({
    super.key,
    required this.letter,
    required this.size,
    required this.radius,
    this.isElevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = LetterColors.forLetter(letter);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isElevated
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: (size * 0.5).sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
