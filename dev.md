architecture: mvvm, layers(data, domain, features), riverpod(state), fake-firebase-service
feature: todos, auth-stub, web-responsive-layout
folder-structure: features/[feature]/[feature]_view.dart, [feature]_view_model.dart, [feature]_state.dart, [feature]_providers.dart
riverpod: codegen @riverpod + *.g.dart; nach Provider-Änderung: dart run build_runner build -d; Notifier.build: async Load via Future.microtask
commands: cd app; flutter run -d chrome
ide: vscode launch "app (web - Chrome)" for flutter web
lint: Future.delayed ohne Callback → Future<void>.delayed (inference_failure_on_instance_creation)

