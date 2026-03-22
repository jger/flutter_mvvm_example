import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/router/app_router.dart';
import 'package:flutter_mvvm_example/data/repositories/todo_repository.dart';
import 'package:flutter_mvvm_example/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/todo_providers.dart';
import 'package:flutter_mvvm_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: shows todos and navigates to config and back', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();

    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    final GoRouter router = createAppRouter();
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
        child: ProviderScope(
          overrides: <Override>[
            firebaseServiceProvider.overrideWithValue(service),
            todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
            todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
          ],
          child: MainApp(router: router),
        ),
      ),
    );
    addTearDown(service.dispose);

    await tester.pumpAndSettle();
    expect(find.text('Learn MVVM Architecture'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Configuration'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Learn MVVM Architecture'), findsOneWidget);
  });
}
