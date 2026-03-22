import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// UI state for the config screen (MVVM).
class ConfigState extends Equatable {
  /// Creates config state with [themeMode].
  const ConfigState({required this.themeMode});

  /// Selected app theme mode (light/dark/system).
  final ThemeMode themeMode;

  /// Resolves light/dark from [themeMode] using [platformBrightness] when system.
  Brightness effectiveBrightness(Brightness platformBrightness) {
    return switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
  }

  @override
  List<Object?> get props => <Object?>[themeMode];
}
