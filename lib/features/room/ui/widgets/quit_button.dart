import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

class QuitButton extends StatelessWidget {
  const QuitButton({
    super.key,
    required this.unit,
    required this.onConfirmQuit,
  });

  final double unit;
  final VoidCallback onConfirmQuit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.all(8 * unit),
        child: IconButton(
          icon: const Icon(Icons.exit_to_app_rounded),
          color: Colors.redAccent,
          tooltip: 'خروج',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'خروج',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'هل تريد الخروج من اللعبة؟',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmQuit();
                    },
                    child: const Text('خروج'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
