import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.background,
      textTheme: _buildTextTheme(AppColor.textPrimary),
      colorScheme: ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        error: AppColor.error,
        surface: AppColor.white,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.textPrimary,
        onError: AppColor.white,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: _sans(18.sp, FontWeight.w600, AppColor.textPrimary),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.inputFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: _inputBorder(AppColor.inputBorder),
        enabledBorder: _inputBorder(AppColor.inputBorder),
        focusedBorder: _inputBorder(AppColor.primary, width: 1.2),
        errorBorder: _inputBorder(AppColor.error),
        focusedErrorBorder: _inputBorder(AppColor.error, width: 1.2),
        hintStyle: _sans(14.sp, FontWeight.w400, AppColor.hintText),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkBackground,
      textTheme: _buildTextTheme(AppColor.white),
      colorScheme: ColorScheme.dark(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        error: AppColor.error,
        surface: AppColor.darkSurface,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.white,
        onError: AppColor.white,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: _sans(18.sp, FontWeight.w600, AppColor.white),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColor.darkBackground2,
        foregroundColor: AppColor.white,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextStyle _sans(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle _serif(double size, FontWeight weight, Color color) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: _serif(32.sp, FontWeight.w700, baseColor),
      displayMedium: _serif(28.sp, FontWeight.w700, baseColor),
      headlineLarge: _sans(24.sp, FontWeight.w600, baseColor),
      headlineMedium: _sans(20.sp, FontWeight.w600, baseColor),
      titleLarge: _sans(18.sp, FontWeight.w600, baseColor),
      titleMedium: _sans(16.sp, FontWeight.w500, baseColor),
      titleSmall: _sans(14.sp, FontWeight.w500, baseColor),
      bodyLarge: _sans(16.sp, FontWeight.w400, baseColor),
      bodyMedium: _sans(14.sp, FontWeight.w400, baseColor),
      bodySmall: _sans(12.sp, FontWeight.w400, baseColor),
      labelLarge: _sans(14.sp, FontWeight.w500, baseColor),
      labelSmall: _sans(11.sp, FontWeight.w400, baseColor),
    );
  }
}
