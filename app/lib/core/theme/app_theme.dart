import 'package:app/core/ui/ui_constants.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: UiConstants.seedColor),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: UiConstants.seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
