import 'package:flutter/material.dart';
import '../../../../core/theming/app_theme.dart';

void showRulesDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const _RulesDialog(),
  );
}

class _RulesDialog extends StatelessWidget {
  const _RulesDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.primaryGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'قواعد اللعبة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),

            // Scrollable rules content
            Flexible(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SectionTitle(icon: Icons.flag_rounded, text: 'الهدف'),
                      _RuleText(
                        'كن أول لاعب يُفرغ يده من الأوراق.',
                      ),

                      SizedBox(height: 14),
                      _SectionTitle(icon: Icons.sports_esports_rounded, text: 'طريقة اللعب'),
                      _NumberedRule(number: '١', text: 'يحصل كل لاعب على 10 أو 15 حرفًا في بداية اللعبة.'),
                      _NumberedRule(number: '٢', text: 'تظهر مفردة ثلاثية مشتركة في ساحة اللعب.'),
                      _NumberedRule(number: '٣', text: 'في دورك: اختر حرفًا من يدك وضعه مكان أي حرف في الكلمة لتكوين كلمة عربية صحيحة جديدة.'),
                      _NumberedRule(number: '٤', text: 'إذا كانت الكلمة صحيحة، ينتقل الدور للاعب التالي.'),
                      _NumberedRule(number: '٥', text: 'لديك ثلاث محاولات في كل دور'),
                      _NumberedRule(number: '٦', text: 'يمكنك سحب حرف إضافي وتمرير دورك بدلًا من اللعب.'),

                      SizedBox(height: 14),
                      _SectionTitle(icon: Icons.help_outline_rounded, text: 'بطاقة الجوكر (?)'),
                      _RuleText('تعمل كأي حرف تختاره عند استخدامها.'),

                      SizedBox(height: 14),
                      _SectionTitle(icon: Icons.timer_rounded, text: 'الوقت'),
                      _RuleText('لكل دور وقت محدد.'),
                      _RuleText('إذا انتهى وقتك 5 مرات متتالية دون لعب، تُستبعد من اللعبة.'),

                      SizedBox(height: 14),
                      _SectionTitle(icon: Icons.warning_amber_rounded, text: 'الخروج من اللعبة'),
                      _RuleText('إذا تجاوزت الحد الأقصى للأوراق (22 ورقة)، تخسر وتخرج من اللعبة.'),

                      SizedBox(height: 14),
                      _SectionTitle(icon: Icons.emoji_events_rounded, text: 'الفوز'),
                      _BulletRule(text: 'أول لاعب يُفرغ يده من الأوراق كليًا يفوز فورًا.'),
                      _BulletRule(text: 'إذا استمرت العبة لوقت طويل، يفوز اللاعب الذي يملك أقل عدد من الأوراق.'),

                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('فهمت!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppTheme.primaryTeal),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primaryTeal,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleText extends StatelessWidget {
  const _RuleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, right: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }
}

class _NumberedRule extends StatelessWidget {
  const _NumberedRule({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(left: 8, top: 1),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletRule extends StatelessWidget {
  const _BulletRule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, left: 8),
            child: Icon(Icons.circle, size: 6, color: AppTheme.primaryGreen),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
