import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/features/todos/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/repositories/todo_repository.dart';
import 'package:flutter_mvvm_example/features/todos/view/todo_view.dart';
import 'package:flutter_mvvm_example/features/todos/viewmodel/todo_providers.dart';
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

  testWidgets('TodosPage shows app bar title', (WidgetTester tester) async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
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
        saveLocale: false,
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
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AppBar), findsOneWidget);
    service.dispose();
  });
}
