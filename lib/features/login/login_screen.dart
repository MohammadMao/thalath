import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theming/app_theme.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/widgets/auth_button.dart';
import '../../core/widgets/responsive_content.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkBackground.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveContent(
            maxWidth: 600,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Text(
                    'ثلاث',
                    style: TextStyle(
                      fontSize: 64.sp,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            AppTheme.primaryTeal,
                            AppTheme.primaryGreen,
                          ],
                        ).createShader(
                          Rect.fromLTWH(0, 0, 200.w, 70.h),
                        ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 60.h),

                  // Email Field
                  AuthTextField(
                    controller: controller.emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  Obx(
                    () => AuthTextField(
                      controller: controller.passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      obscureText: controller.obscurePassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Login Button
                  Obx(
                    () => AuthButton(
                      text: 'دخول',
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Back to Home
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
