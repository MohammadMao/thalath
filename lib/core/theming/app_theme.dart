import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Colors - Light teal to light green gradient palette
  static const Color primaryTeal = Color(0xFF26D0CE);
  static const Color primaryGreen = Color(0xFF1DBF73);
  static const Color accentTeal = Color(0xFF6FFFE9);
  static const Color accentGreen = Color(0xFF5FE3A1);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF1A1F3A);
  static const Color cardDark = Color(0xFF252B48);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BFD8);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: primaryGreen,
        surface: darkSurface,
        // background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        // onBackground: textPrimary,
      ),
      
      // Card theme - modern rounded cards
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Elevated Button theme - modern rounded
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration theme - rounded
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 64.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          color: textSecondary,
        ),
      ),
    );
  }
}
