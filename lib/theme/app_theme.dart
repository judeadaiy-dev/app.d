import 'package:flutter/material.dart';
import 'package:chat_app/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background, // ابيض
    
    colorScheme: ColorScheme.light(
      primary: AppColors.primary, // بنفسجي
      secondary: AppColors.accent,
      surface: AppColors.background, // ابيض
      onPrimary: AppColors.primaryForeground, // ابيض داخل البنفسجي
      onSurface: AppColors.textPrimary, // اسود للنصوص
    ),
    
    // الأيقونات - سوداء
    iconTheme: const IconThemeData(
      color: AppColors.iconLight, // اسود
      size: 24,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background, // ابيض
      foregroundColor: AppColors.textPrimary, // اسود للعنوان
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.iconLight), // اسود
    ),
    
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.card, // ابيض
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
    ),
    
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.background, // ابيض
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary, // اسود
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary, // اسود
        fontSize: 16,
        fontFamily: 'Cairo',
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: AppColors.textPrimary), // اسود
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    
    // الأزرار - بنفسجي + نص ابيض
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // بنفسجي #824C97
        foregroundColor: AppColors.primaryForeground, // ابيض
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // بنفسجي
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary), // اسود
      displayMedium: TextStyle(color: AppColors.textPrimary),
      displaySmall: TextStyle(color: AppColors.textPrimary),
      headlineLarge: TextStyle(color: AppColors.textPrimary),
      headlineMedium: TextStyle(color: AppColors.textPrimary),
      headlineSmall: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary),
      titleMedium: TextStyle(color: AppColors.textPrimary),
      titleSmall: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background, // ابيض
      selectedItemColor: AppColors.primary, // بنفسجي
      unselectedItemColor: AppColors.iconLight, // اسود
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark, // #3f3f3f
    
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary, // بنفسجي
      secondary: AppColors.accent,
      surface: AppColors.backgroundDark, // #3f3f3f
      onPrimary: AppColors.primaryForeground, // ابيض
      onSurface: AppColors.textPrimaryDark, // ابيض
    ),
    
    // الأيقونات - بيضاء
    iconTheme: const IconThemeData(
      color: AppColors.iconDark, // ابيض
      size: 24,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark, // #3f3f3f
      foregroundColor: AppColors.textPrimaryDark, // ابيض
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.iconDark), // ابيض
    ),
    
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.cardDark, // رمادي افتح
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.backgroundDark, // #3f3f3f
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimaryDark, // ابيض
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimaryDark, // ابيض
        fontSize: 16,
        fontFamily: 'Cairo',
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF4A4A4A),
      hintStyle: TextStyle(color: Colors.grey[400]),
      labelStyle: const TextStyle(color: AppColors.textPrimaryDark), // ابيض
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    
    // الأزرار - كحلي + بنفسجي + نص ابيض
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButton, // كحلي #2C2C3E
        foregroundColor: AppColors.primaryForeground, // ابيض
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // بنفسجي
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimaryDark), // ابيض
      displayMedium: TextStyle(color: AppColors.textPrimaryDark),
      displaySmall: TextStyle(color: AppColors.textPrimaryDark),
      headlineLarge: TextStyle(color: AppColors.textPrimaryDark),
      headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
      headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
      titleLarge: TextStyle(color: AppColors.textPrimaryDark),
      titleMedium: TextStyle(color: AppColors.textPrimaryDark),
      titleSmall: TextStyle(color: AppColors.textPrimaryDark),
      bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
      bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
      bodySmall: TextStyle(color: AppColors.textSecondaryDark),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark, // #3f3f3f
      selectedItemColor: AppColors.primary, // بنفسجي
      unselectedItemColor: AppColors.iconDark, // ابيض
    ),
  );
}
