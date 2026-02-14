import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theming/app_theme.dart';
import 'core/auth/auth_service.dart';
import 'features/home/ui/home_screen.dart';
import 'features/login/login_screen.dart';
import 'features/lobby/ui/lobby_screen.dart';
import 'features/room/ui/room_screen.dart';

class ThalathApp extends StatelessWidget {
  const ThalathApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthService
    Get.put(AuthService());

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (iPhone 11 Pro)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Thalath - ثلاث',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const HomePage(),
          getPages: [
            GetPage(
              name: '/home',
              page: () => const HomePage(),
            ),
            GetPage(
              name: '/login',
              page: () => const LoginScreen(),
            ),
            GetPage(
              name: '/rooms',
              page: () => const RoomsPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: '/room',
              page: () => const RoomScreen(),
              middlewares: [AuthMiddleware()],
            ),
          ],
        );
      },
    );
  }
}

// Auth Middleware to protect routes
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
