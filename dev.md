code-comments: English (Dart // and ///)
architecture: mvvm, layers(data, domain, features), riverpod(state), fake-firebase-service, TodoRepository
feature: todos (pull-to-refresh), stream watchTodos + init getTodos, auth-stub, web-responsive-layout, easy_localization en/de/el (assets/translations), AppBar language menu + theme toggle (AppThemeMode + SharedPreferences)
folder-structure: core/theme (AppTheme, theme_mode_provider), core/ui (UiConstants); features/[feature]/[feature]_view.dart, [feature]_view_model.dart, [feature]_state.dart, [feature]_providers.dart; data/repositories/todo_repository.dart
riverpod: codegen @riverpod + *.g.dart; nach Provider-Änderung: dart run build_runner build -d; VM: ref.watch(todoRepositoryProvider), watchTodos.listen + Future.microtask(_loadTodos), ref.mounted nach async; tests: container.listen gegen autoDispose
commands: cd app; flutter pub get; dart run build_runner build -d; flutter test; flutter run -d chrome
ci: .github/workflows/flutter.yml (app/)
ide: vscode launch "app (web - Chrome)" for flutter web
lint: Future.delayed ohne Callback → Future<void>.delayed (inference_failure_on_instance_creation)
hiring-review: docs/hiring-review/01-missing.md … 04-questions.md (Tech-Lead-Codebase-Review, nicht committen); 01: Abschnitte Tests/CI/UX/Arch/Observability/Doku/Security

