import 'package:app/features/settings/config_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = const Locale('en');

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('ConfigPage golden', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('de'),
          Locale('el'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const ProviderScope(child: MaterialApp(home: ConfigPage())),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(ConfigPage),
      matchesGoldenFile('goldens/config_page.png'),
    );
  }, tags: <String>['golden']);
}
