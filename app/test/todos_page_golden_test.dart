import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/data/repositories/todo_repository.dart';
import 'package:flutter_mvvm_example/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/todo_providers.dart';
import 'package:flutter_mvvm_example/features/todos/todo_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  // Both PNGs in one test: a follow-up testWidgets after matchesGoldenFile can drop the FAB.
  testWidgets('TodosPage goldens (closed + composer open)', (
    WidgetTester tester,
  ) async {
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
          child: localizedMaterialApp(home: const TodosPage()),
        ),
      ),
    );
    await tester.pump();
    await pumpUntilFakeTodoListRendered(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(TodosPage),
      matchesGoldenFile('goldens/todos_page.png'),
    );

    await pumpUntilFound(tester, find.byKey(const Key('todo_fab_expand')));
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
