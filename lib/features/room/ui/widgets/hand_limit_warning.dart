import 'package:flutter/material.dart';

class HandLimitWarning extends StatelessWidget {
  const HandLimitWarning({
    super.key,
    required this.unit,
    required this.isVisible,
  });

  final double unit;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 8 * unit),
      child: Text(
        'وصلت حد الورق المسموح، السحبة الجاية خسارة :(',
        style: TextStyle(
          color: Colors.red,
          fontSize: 11 * unit,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
