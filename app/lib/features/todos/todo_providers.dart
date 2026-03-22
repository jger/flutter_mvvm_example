import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart';

/// Default or overridden initial filter/sort (overridden in `main.dart`).
@riverpod
TodoInitialUi todoInitialUi(Ref ref) {
  return TodoInitialUi.defaults;
}

/// Shared in-memory backend; disposed with the provider.
@riverpod
FakeFirebaseService firebaseService(Ref ref) {
  final FakeFirebaseService service = FakeFirebaseService();
  ref.onDispose(service.dispose);
  return service;
}

/// Repository bound to [firebaseServiceProvider].
@riverpod
TodoRepository todoRepository(Ref ref) {
  return TodoRepository(ref.watch(firebaseServiceProvider));
}
