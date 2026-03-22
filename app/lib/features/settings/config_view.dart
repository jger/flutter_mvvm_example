import 'package:app/features/settings/config_state.dart';
import 'package:app/features/settings/config_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings screen: theme toggle and language.
class ConfigPage extends ConsumerWidget {
  /// Creates the config page.
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigState state = ref.watch(configViewModelProvider);
    final ConfigViewModel viewModel = ref.read(
      configViewModelProvider.notifier,
    );
    final Brightness platform = MediaQuery.platformBrightnessOf(context);
    final Brightness effective = state.effectiveBrightness(platform);

    return Scaffold(
      appBar: AppBar(
        title: Text('configTitle'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            leading: Icon(
              effective == Brightness.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            title: Text('themeSectionTitle'.tr()),
            trailing: IconButton(
              tooltip: 'themeToggleTooltip'.tr(),
              onPressed: () => viewModel.toggleTheme(platform),
              icon: Icon(
                effective == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text('languageSectionTitle'.tr()),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: context.locale,
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    context.setLocale(locale);
                  }
                },
                items: <DropdownMenuItem<Locale>>[
                  DropdownMenuItem<Locale>(
                    value: const Locale('en'),
                    child: Text('languageEnglish'.tr()),
                  ),
                  DropdownMenuItem<Locale>(
                    value: const Locale('de'),
                    child: Text('languageGerman'.tr()),
                  ),
                  DropdownMenuItem<Locale>(
                    value: const Locale('el'),
                    child: Text('languageGreek'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
