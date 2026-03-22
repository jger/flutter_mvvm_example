import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/theme/theme_mode_provider.dart';
import 'package:flutter_mvvm_example/features/settings/config_state.dart';
import 'package:flutter_mvvm_example/features/settings/config_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'toggleTheme switches from system with light platform to dark',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final ProviderSubscription<ConfigState> sub = container
          .listen<ConfigState>(
            configViewModelProvider,
            (ConfigState? previous, ConfigState next) {},
          );
      addTearDown(sub.close);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final ConfigViewModel vm = container.read(
        configViewModelProvider.notifier,
      );
      await vm.toggleTheme(Brightness.light);
      expect(container.read(appThemeModeProvider), ThemeMode.dark);
    },
  );
}
