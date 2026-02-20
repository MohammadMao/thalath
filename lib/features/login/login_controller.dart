import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/services/user_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    // Validate inputs
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال كلمة المرور',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _ensureUserProfile();

      // Navigate to lobby on success
      Get.offAllNamed('/rooms');

      Get.snackbar(
        'نجح',
        'تم تسجيل الدخول بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _ensureUserProfile() async {
    try {
      await _userService.ensureUserDocument();
    } on StateError catch (e) {
      if (e.message != 'missing-display-name') {
        rethrow;
      }

      final name = await _promptForName();
      if (name == null || name.trim().isEmpty) {
        throw 'يرجى إدخال الاسم';
      }

      _userService.setDisplayName(name);
      await _userService.ensureUserDocument();
    }
  }

  Future<String?> _promptForName() async {
    final controller = TextEditingController();

    final result = await Get.dialog<String>(
      AlertDialog(
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'اختر اسماً',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('تأكيد'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    controller.dispose();
    return result;
  }
}
