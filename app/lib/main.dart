import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mvvm_example/core/router/app_router.dart';
import 'package:flutter_mvvm_example/core/theme/app_theme.dart';
import 'package:flutter_mvvm_example/core/theme/theme_mode_provider.dart';
import 'package:flutter_mvvm_example/data/local/todo_persistence.dart';
import 'package:flutter_mvvm_example/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/domain/models/todo.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/todo_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await EasyLocalization.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FakeFirebaseService firebase = FakeFirebaseService(
    seedTodos: TodoPersistence.load(prefs),
    onPersist: (List<Todo> todos) => TodoPersistence.save(prefs, todos),
  );
  final TodoInitialUi initialUi = TodoPersistence.loadInitialUi(prefs);
  final GoRouter router = createAppRouter();
  runApp(
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
          firebaseServiceProvider.overrideWithValue(firebase),
          todoInitialUiProvider.overrideWithValue(initialUi),
        ],
        child: MainApp(router: router),
      ),
    ),
  );
}

/// Root [MaterialApp.router] with theme and localization from providers.
class MainApp extends ConsumerWidget {
  /// Creates the app with [router] from [createAppRouter].
  const MainApp({required this.router, super.key});

  /// GoRouter configuration for navigation.
  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => 'appTitle'.tr(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}
