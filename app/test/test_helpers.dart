import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// [MaterialApp] must use EasyLocalization delegates or `.tr()` keys stay unresolved (wrong goldens/CI).
Widget localizedMaterialApp({required Widget home}) {
  return Builder(
    builder: (BuildContext context) => MaterialApp(
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

/// Waits for [FakeFirebaseService] seed todos + paged load (avoids spinner-only goldens).
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
