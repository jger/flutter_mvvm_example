import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:app/features/todos/todo_providers.dart';
import 'package:app/features/todos/todo_state.dart';
import 'package:app/features/todos/todo_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

void main() {
  test(
    'TodosViewModel loads todos from stream without wall-clock delay',
    () async {
      final FakeFirebaseService service = FakeFirebaseService(
        actionDelay: Duration.zero,
        fetchDelay: Duration.zero,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          firebaseServiceProvider.overrideWithValue(service),
          todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
          todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
        ],
      );
      final ProviderSubscription<TodosState> sub = container.listen<TodosState>(
        todosViewModelProvider,
        (TodosState? previous, TodosState next) {},
      );
      addTearDown(sub.close);
      addTearDown(container.dispose);
      addTearDown(service.dispose);
      await Future<void>.delayed(Duration.zero);
      final TodosState state = container.read(todosViewModelProvider);
      expect(state.todos.length, 2);
      expect(state.isLoading, isFalse);
    },
  );

  test('refresh sets isRefreshing then clears', () async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        firebaseServiceProvider.overrideWithValue(service),
        todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
        todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
      ],
    );
    final ProviderSubscription<TodosState> sub = container.listen<TodosState>(
      todosViewModelProvider,
      (TodosState? previous, TodosState next) {},
    );
    addTearDown(sub.close);
    addTearDown(container.dispose);
    addTearDown(service.dispose);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(todosViewModelProvider).isRefreshing, isFalse);
    final Future<void> done = vm.refresh();
    expect(container.read(todosViewModelProvider).isRefreshing, isTrue);
    await done;
    expect(container.read(todosViewModelProvider).isRefreshing, isFalse);
  });

  test('loadMore appends next page when list exceeds page size', () async {
    final List<Todo> seed = List<Todo>.generate(
      25,
      (int i) => Todo(
        id: 'id_$i',
        title: 'task $i',
        isCompleted: false,
        createdAt: DateTime(2024, 1, i + 1),
      ),
    );
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
      seedTodos: seed,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        firebaseServiceProvider.overrideWithValue(service),
        todoRepositoryProvider.overrideWithValue(TodoRepository(service)),
        todoInitialUiProvider.overrideWithValue(TodoInitialUi.defaults),
      ],
    );
    final ProviderSubscription<TodosState> sub = container.listen<TodosState>(
      todosViewModelProvider,
      (TodosState? previous, TodosState next) {},
    );
    addTearDown(sub.close);
    addTearDown(container.dispose);
    addTearDown(service.dispose);
    await Future<void>.delayed(Duration.zero);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    TodosState s = container.read(todosViewModelProvider);
    expect(s.allTodos.length, 25);
    expect(s.todos.length, 20);
    expect(s.hasMore, isTrue);
    await vm.loadMore();
    s = container.read(todosViewModelProvider);
    expect(s.todos.length, 25);
    expect(s.hasMore, isFalse);
  });
}
