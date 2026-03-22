import 'package:flutter_mvvm_example/data/repositories/todo_repository.dart';
import 'package:flutter_mvvm_example/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/domain/models/todo.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/todo_providers.dart';
import 'package:flutter_mvvm_example/features/todos/todo_state.dart';
import 'package:flutter_mvvm_example/features/todos/todo_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

/// Fails [addTodo] once, then delegates to [FakeFirebaseService].
class _FailOnceAddService extends FakeFirebaseService {
  _FailOnceAddService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  int _attempts = 0;

  @override
  Future<Todo> addTodo(String title) async {
    _attempts++;
    if (_attempts == 1) {
      throw Exception('add failed');
    }
    return super.addTodo(title);
  }
}

/// Emits a stream error instead of snapshots.
class _StreamErrorService extends FakeFirebaseService {
  _StreamErrorService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Stream<List<Todo>> watchTodos() {
    return Stream<List<Todo>>.error(Exception('stream boom'));
  }
}

/// Throws on [getTodos] (pull-to-refresh path).
class _FailingGetTodosService extends FakeFirebaseService {
  _FailingGetTodosService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<List<Todo>> getTodos() async {
    throw Exception('refresh fail');
  }
}

/// Throws on [getTodosPage] when paging past the first page.
class _FailingLoadMoreService extends FakeFirebaseService {
  _FailingLoadMoreService({required List<Todo> super.seedTodos})
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
    required TodoFilter filter,
    required TodoSort sort,
  }) async {
    if (offset > 0) {
      throw Exception('load more fail');
    }
    return super.getTodosPage(
      offset: offset,
      limit: limit,
      filter: filter,
      sort: sort,
    );
  }
}

/// First-page reload after stream emission fails.
class _FailingFirstPageService extends FakeFirebaseService {
  _FailingFirstPageService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
    required TodoFilter filter,
    required TodoSort sort,
  }) async {
    if (offset == 0) {
      throw Exception('first page fail');
    }
    return super.getTodosPage(
      offset: offset,
      limit: limit,
      filter: filter,
      sort: sort,
    );
  }
}

class _FailingToggleService extends FakeFirebaseService {
  _FailingToggleService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<Todo> updateTodo(Todo todo) async {
    throw Exception('toggle fail');
  }
}

class _FailingDeleteService extends FakeFirebaseService {
  _FailingDeleteService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<void> deleteTodo(String id) async {
    throw Exception('delete fail');
  }
}

class _FailingAddService extends FakeFirebaseService {
  _FailingAddService()
    : super(actionDelay: Duration.zero, fetchDelay: Duration.zero);

  @override
  Future<Todo> addTodo(String title) async {
    throw Exception('add fail');
  }
}

void main() {
  Future<void> settle(ProviderContainer container) async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('watchTodos stream error sets error on state', () async {
    final _StreamErrorService service = _StreamErrorService();
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
    await settle(container);
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNotNull);
    expect(state.error, contains('Exception'));
    expect(state.isLoading, isFalse);
  });

  test('addTodo failure sets error and TodoAddOp pendingRetry', () async {
    final _FailingAddService service = _FailingAddService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.addTodo('hello');
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNotNull);
    expect(state.pendingRetry, isA<TodoAddOp>());
    expect((state.pendingRetry! as TodoAddOp).title, 'hello');
  });

  test('addTodo blank title does nothing', () async {
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    final TodosState before = container.read(todosViewModelProvider);
    await vm.addTodo('   ');
    final TodosState after = container.read(todosViewModelProvider);
    expect(after.error, before.error);
    expect(after.pendingRetry, before.pendingRetry);
  });

  test('toggleTodo failure sets TodoToggleOp', () async {
    final _FailingToggleService service = _FailingToggleService();
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
    await settle(container);
    final TodosState loaded = container.read(todosViewModelProvider);
    final Todo first = loaded.allTodos.first;
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.toggleTodo(first);
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.pendingRetry, isA<TodoToggleOp>());
    expect((state.pendingRetry! as TodoToggleOp).todo.id, first.id);
  });

  test('deleteTodo failure sets TodoDeleteOp', () async {
    final _FailingDeleteService service = _FailingDeleteService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.deleteTodo('1');
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.pendingRetry, isA<TodoDeleteOp>());
    expect((state.pendingRetry! as TodoDeleteOp).id, '1');
  });

  test('updateTodoTitle failure sets TodoEditTitleOp', () async {
    final _FailingToggleService service = _FailingToggleService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.updateTodoTitle('1', 'new title');
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.pendingRetry, isA<TodoEditTitleOp>());
    final TodoEditTitleOp op = state.pendingRetry! as TodoEditTitleOp;
    expect(op.id, '1');
    expect(op.newTitle, 'new title');
  });

  test('updateTodoTitle unknown id is no-op', () async {
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.updateTodoTitle('no-such-id', 'x');
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNull);
    expect(state.pendingRetry, isNull);
  });

  test('refresh failure sets error', () async {
    final _FailingGetTodosService service = _FailingGetTodosService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.refresh();
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNotNull);
    expect(state.isRefreshing, isFalse);
  });

  test('loadMore failure sets error', () async {
    final List<Todo> seed = List<Todo>.generate(
      25,
      (int i) => Todo(
        id: 'id_$i',
        title: 'task $i',
        isCompleted: false,
        createdAt: DateTime(2024, 1, i + 1),
      ),
    );
    final _FailingLoadMoreService service = _FailingLoadMoreService(
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.loadMore();
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNotNull);
    expect(state.isLoadingMore, isFalse);
  });

  test('_reloadFirstPage failure sets error after stream emit', () async {
    final _FailingFirstPageService service = _FailingFirstPageService();
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
    await settle(container);
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.error, isNotNull);
    expect(state.isLoadingMore, isFalse);
  });

  test('dismissRetry clears pendingRetry', () async {
    final _FailingAddService service = _FailingAddService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.addTodo('x');
    expect(container.read(todosViewModelProvider).pendingRetry, isNotNull);
    vm.dismissRetry();
    expect(container.read(todosViewModelProvider).pendingRetry, isNull);
  });

  test('retryLastFailed succeeds after transient add failure', () async {
    final _FailOnceAddService service = _FailOnceAddService();
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
    await settle(container);
    final TodosViewModel vm = container.read(todosViewModelProvider.notifier);
    await vm.addTodo('retry me');
    TodosState state = container.read(todosViewModelProvider);
    expect(state.pendingRetry, isA<TodoAddOp>());
    await vm.retryLastFailed();
    state = container.read(todosViewModelProvider);
    expect(state.pendingRetry, isNull);
    expect(state.error, isNull);
    expect(state.allTodos.any((Todo t) => t.title == 'retry me'), isTrue);
  });
}
