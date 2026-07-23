import 'package:flutter/material.dart';

extension AppTextStyles on BuildContext {
  /// Poppins • 32sp • w700
  TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge!;

  /// Poppins • 28sp • w700
  TextStyle get displayMedium => Theme.of(this).textTheme.displayMedium!;

  /// Poppins • 24sp • w600
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;

  /// Poppins • 20sp • w600
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;

  /// Poppins • 18sp • w600
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;

  /// Poppins • 16sp • w500
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;

  /// Poppins • 14sp • w500
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;

  /// Poppins • 16sp • w400
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;

  /// Poppins • 14sp • w400
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;

  /// Poppins • 12sp • w400
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;

  /// Poppins • 14sp • w500
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;

  /// Poppins • 11sp • w400
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;
}
