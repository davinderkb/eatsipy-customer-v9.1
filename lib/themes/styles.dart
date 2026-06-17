import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:flutter/material.dart';

class Styles {
  static ColorScheme _lightColorScheme() {
    return ColorScheme.light(
      primary: AppThemeData.primary300,
      onPrimary: AppThemeData.grey50,
      primaryContainer: AppThemeData.primary50,
      onPrimaryContainer: AppThemeData.primary600,
      secondary: AppThemeData.secondary300,
      onSecondary: AppThemeData.grey50,
      secondaryContainer: AppThemeData.secondary50,
      onSecondaryContainer: AppThemeData.secondary600,
      tertiary: AppThemeData.info300,
      onTertiary: AppThemeData.grey50,
      error: AppThemeData.danger300,
      onError: AppThemeData.grey50,
      surface: AppThemeData.surface,
      onSurface: AppThemeData.grey900,
      surfaceContainerHighest: AppThemeData.grey100,
      outline: AppThemeData.grey300,
      outlineVariant: AppThemeData.grey200,
    );
  }

  static ColorScheme _darkColorScheme() {
    return ColorScheme.dark(
      primary: AppThemeData.primary300,
      onPrimary: AppThemeData.grey900,
      primaryContainer: AppThemeData.primary600,
      onPrimaryContainer: AppThemeData.primary100,
      secondary: AppThemeData.secondary300,
      onSecondary: AppThemeData.grey900,
      secondaryContainer: AppThemeData.secondary600,
      onSecondaryContainer: AppThemeData.secondary100,
      tertiary: AppThemeData.info300,
      onTertiary: AppThemeData.grey900,
      error: AppThemeData.danger300,
      onError: AppThemeData.grey900,
      surface: AppThemeData.surfaceDark,
      onSurface: AppThemeData.grey50,
      surfaceContainerHighest: AppThemeData.grey800,
      outline: AppThemeData.grey600,
      outlineVariant: AppThemeData.grey700,
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
      displayMedium: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      displaySmall: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      headlineLarge: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      headlineMedium: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      headlineSmall: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      titleLarge: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      titleMedium: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
      titleSmall: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
      bodyLarge: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
      bodyMedium: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
      bodySmall: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
      labelLarge: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      labelMedium: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
      labelSmall: TextStyle(fontFamily: AppThemeData.fontFamily, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
    );
  }

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    final colorScheme = isDarkTheme ? _darkColorScheme() : _lightColorScheme();
    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      primaryColor: colorScheme.primary,
      brightness: colorScheme.brightness,
      fontFamily: AppThemeData.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppThemeData.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDarkTheme ? AppThemeData.grey900 : AppThemeData.grey50,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: AppThemeData.fontFamily,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withAlpha(128),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: AppThemeData.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDarkTheme ? AppThemeData.grey700 : AppThemeData.grey300,
        dialTextStyle: TextStyle(fontWeight: FontWeight.bold, color: AppThemeData.grey800),
        dialTextColor: AppThemeData.grey800,
        hourMinuteTextColor: AppThemeData.grey800,
        dayPeriodTextColor: AppThemeData.grey800,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDarkTheme ? AppThemeData.grey900 : AppThemeData.grey50,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppThemeData.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: colorScheme.onSurface,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 22);
          }
          return IconThemeData(
            color: isDarkTheme ? AppThemeData.grey300 : AppThemeData.grey600,
            size: 22,
          );
        }),
      ),
    );
  }
}
