import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/services/user_service.dart';

class UserNameEdit extends StatefulWidget {
  const UserNameEdit({super.key});

  @override
  State<UserNameEdit> createState() => _UserNameEditState();
}

class _UserNameEditState extends State<UserNameEdit> {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = Get.find<UserService>();
    _userService.fetchUserName();
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: _userService.displayName.value ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'اكتب اسمك الجديد',
            ),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  Get.snackbar(
                    'خطأ',
                    'الاسم لا يمكن أن يكون فارغًا',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                try {
                  await _userService.updateUserName(newName);
                  if (context.mounted) Navigator.of(dialogContext).pop();
                } catch (_) {
                  Get.snackbar(
                    'خطأ',
                    'تعذر تحديث الاسم',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showEditNameDialog(context),
        child: Obx(() {
          final name = _userService.displayName.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name == null || name.isEmpty ? 'لاعب' : name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.edit_rounded,
                size: 16.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          );
        }),
      ),
    );
  }
}
