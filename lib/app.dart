import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theming/app_theme.dart';
import 'core/auth/auth_service.dart';
import 'core/services/user_service.dart';
import 'core/services/room_service.dart';
import 'core/services/sound_service.dart';
import 'features/home/ui/home_screen.dart';
import 'features/login/login_screen.dart';
import 'features/lobby/ui/lobby_screen.dart';
import 'features/room/ui/room_screen.dart';
import 'features/splash/splash_screen.dart';

class ThalathApp extends StatelessWidget {
  const ThalathApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthService
    Get.put(AuthService());
    Get.put(UserService());
    Get.put(RoomService());
    Get.put(SoundService());

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final isWeb = kIsWeb;
    final clampedWebWidth = logicalSize.width.clamp(700.0, 1200.0);
    final clampedWebHeight = logicalSize.height.clamp(700.0, 1000.0);
    final designSize = isWeb
        ? Size(clampedWebWidth, clampedWebHeight)
        : const Size(375, 812);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Thalath - ثلاث',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
          getPages: [
            GetPage(name: '/splash', page: () => const SplashScreen()),
            GetPage(name: '/home', page: () => const HomePage()),
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(
              name: '/lobby',
              page: () => const LobbyScreen(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: '/room',
              page: () {
                final args = Get.arguments as Map<String, dynamic>;
                return RoomScreen(roomId: args['roomId']);
              },
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
