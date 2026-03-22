import 'package:app/core/ui/ui_constants.dart';
import 'package:flutter/material.dart';

/// Application light/dark [ThemeData] factories.
abstract final class AppTheme {
  /// Light theme using [UiConstants.seedColor] as seed.
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: UiConstants.seedColor),
      useMaterial3: true,
    );
  }

  /// Dark theme using [UiConstants.seedColor] as seed.
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
