import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Material 3 default splash uses [InkSparkle], which loads `shaders/ink_sparkle.frag` and can throw
/// in `flutter test` (engine / asset format mismatch). Use classic [InkRipple] in tests.
ThemeData themeForWidgetTests() {
  return ThemeData(
    useMaterial3: true,
    splashFactory: InkRipple.splashFactory,
  );
}

/// [MaterialApp] must wire [EasyLocalization] delegates + locale or `.tr()` logs missing-key warnings.
/// Use for goldens / tests that assert on translated strings; interaction tests often use a plain
/// [MaterialApp] under [EasyLocalization] plus `saveLocale: false` for stable sequential runs.
Widget localizedMaterialApp({required Widget home}) {
  return Builder(
    builder: (BuildContext context) => MaterialApp(
      theme: themeForWidgetTests(),
      darkTheme: themeForWidgetTests(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: home,
    ),
  );
}

/// Pumps until finder matches (avoids pumpAndSettle on endless animations).
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}

/// Waits for FakeFirebaseService seed todos + paged load (avoids spinner-only goldens).
Future<void> pumpUntilFakeTodoListRendered(WidgetTester tester) async {
  final Finder checkboxes = find.byType(Checkbox);
  for (int i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (checkboxes.evaluate().length >= 2) {
      return;
    }
  }
  expect(checkboxes, findsNWidgets(2));
}
