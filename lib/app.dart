import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theming/app_theme.dart';
import 'features/home/ui/home_page.dart';
import 'features/room/ui/rooms_page.dart';

class ThalathApp extends StatelessWidget {
  const ThalathApp({super.key});

  @override
  Widget build(BuildContext context) {
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
              name: '/rooms',
              page: () => const RoomsPage(),
            ),
          ],
        );
      },
    );
  }
}
