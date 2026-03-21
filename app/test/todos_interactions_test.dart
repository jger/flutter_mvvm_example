import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';
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

class _FailingAddFirebaseService extends FakeFirebaseService {
  _FailingAddFirebaseService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<Todo> addTodo(String title) async {
    throw Exception('add failed');
  }
}

Widget _pumpApp({required FakeFirebaseService service}) {
  return EasyLocalization(
    supportedLocales: const <Locale>[
      Locale('en'),
      Locale('de'),
      Locale('el'),
    ],
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
  );
}

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = const Locale('en');
  SharedPreferences.setMockInitialValues(<String, Object>{});

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('toggle updates checkbox', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    await tester.pumpWidget(_pumpApp(service: service));
    await pumpUntilFound(tester, find.byKey(const ValueKey<String>('todo_checkbox_1')));
    final Finder cb = find.byKey(const ValueKey<String>('todo_checkbox_1'));
    expect(tester.widget<Checkbox>(cb).value, isFalse);
    await tester.tap(cb);
    await tester.pump();
    expect(tester.widget<Checkbox>(cb).value, isTrue);
    service.dispose();
  });

  testWidgets('delete removes item', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    await tester.pumpWidget(_pumpApp(service: service));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey<String>('todo_delete_1')),
    );
    await tester.tap(find.byKey(const ValueKey<String>('todo_delete_1')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Learn MVVM Architecture'), findsNothing);
    service.dispose();
  });

  testWidgets('pull to refresh completes', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: const Duration(milliseconds: 50),
    );
    await tester.pumpWidget(_pumpApp(service: service));
    await pumpUntilFound(tester, find.byType(ListView));
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pump(const Duration(milliseconds: 200));
    service.dispose();
  });

  testWidgets('add failure shows error banner', (WidgetTester tester) async {
    final _FailingAddFirebaseService service = _FailingAddFirebaseService();
    await tester.pumpWidget(_pumpApp(service: service));
    await pumpUntilFound(tester, find.byKey(const Key('todo_fab_expand')));
    await tester.tap(find.byKey(const Key('todo_fab_expand')));
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntilFound(tester, find.byKey(const Key('todo_input_field')));
    await tester.enterText(find.byKey(const Key('todo_input_field')), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.error), findsOneWidget);
    service.dispose();
  });

  testWidgets('empty seed shows empty state', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
      seedTodos: <Todo>[],
    );
    await tester.pumpWidget(_pumpApp(service: service));
    await pumpUntilFound(tester, find.byKey(const Key('empty_state_message')));
    service.dispose();
  });
}
