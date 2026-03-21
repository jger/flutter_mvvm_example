import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// UI state for the config screen (MVVM).
class ConfigState extends Equatable {
  const ConfigState({required this.themeMode});

  final ThemeMode themeMode;

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
