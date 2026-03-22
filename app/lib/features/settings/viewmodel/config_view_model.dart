import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/theme/theme_mode_provider.dart';
import 'package:flutter_mvvm_example/features/settings/models/config_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_view_model.g.dart';

/// ViewModel for app configuration (theme; locale is applied in the view via EasyLocalization).
@riverpod
class ConfigViewModel extends _$ConfigViewModel {
  @override
  ConfigState build() {
    final ThemeMode mode = ref.watch(appThemeModeProvider);
    return ConfigState(themeMode: mode);
  }

  /// Switches between light and dark based on current mode and [platformBrightness].
  Future<void> toggleTheme(Brightness platformBrightness) {
    return ref.read(appThemeModeProvider.notifier).toggle(platformBrightness);
  }
}
