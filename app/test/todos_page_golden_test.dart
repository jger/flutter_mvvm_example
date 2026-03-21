import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:app/features/todos/todo_providers.dart';
import 'package:app/features/todos/todo_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = const Locale('en');

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('TodosPage golden', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: ProviderScope(
          overrides: <Override>[
            firebaseServiceProvider.overrideWithValue(service),
            todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
            todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
          ],
          child: const MaterialApp(home: TodosPage()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(TodosPage),
      matchesGoldenFile('goldens/todos_page.png'),
    );
    service.dispose();
  }, tags: <String>['golden']);

  testWidgets('TodosPage golden composer open', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: ProviderScope(
          overrides: <Override>[
            firebaseServiceProvider.overrideWithValue(service),
            todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
            todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
          ],
          child: const MaterialApp(home: TodosPage()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('todo_fab_expand')));
    await pumpUntilFound(tester, find.byKey(const Key('todo_input_field')));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(TodosPage),
      matchesGoldenFile('goldens/todos_page_composer_open.png'),
    );
    service.dispose();
  }, tags: <String>['golden']);
}
