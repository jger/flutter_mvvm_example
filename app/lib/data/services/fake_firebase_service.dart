import 'dart:async';
import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_filters.dart';

abstract class FirebaseService {
  Stream<List<Todo>> watchTodos();
  Future<List<Todo>> getTodos();

  /// Paged reads; a real backend would apply [filter]/[sort] server-side and return a slice.
  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
    required TodoFilter filter,
    required TodoSort sort,
  });
  Future<Todo> addTodo(String title);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}

typedef TodoPersistCallback = Future<void> Function(List<Todo> todos);

class FakeFirebaseService implements FirebaseService {
  FakeFirebaseService({
    this.actionDelay = const Duration(milliseconds: 200),
    this.fetchDelay = const Duration(milliseconds: 300),
    List<Todo>? seedTodos,
    this.onPersist,
  }) {
    if (seedTodos != null) {
      _todos.addAll(seedTodos);
    } else {
      _seedDefaults();
    }
    _controller = StreamController<List<Todo>>.broadcast(
      onListen: _emitSnapshot,
    );
  }

  final Duration actionDelay;
  final Duration fetchDelay;
  final TodoPersistCallback? onPersist;

  final List<Todo> _todos = <Todo>[];
  late final StreamController<List<Todo>> _controller;

  void _seedDefaults() {
    _todos.addAll(<Todo>[
      Todo(
        id: '1',
        title: 'Learn MVVM Architecture',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Todo(
        id: '2',
        title: 'Build Todo App',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  Future<void> _delay(Duration d) async {
    if (d > Duration.zero) {
      await Future<void>.delayed(d);
    }
  }

  Future<void> _persist() async {
    final TodoPersistCallback? persist = onPersist;
    if (persist != null) {
      await persist(List<Todo>.unmodifiable(_todos));
    }
  }

  void _emitSnapshot() {
    if (!_controller.isClosed) {
      _controller.add(List<Todo>.unmodifiable(_todos));
    }
  }

  @override
  Stream<List<Todo>> watchTodos() => _controller.stream;

  @override
  Future<List<Todo>> getTodos() async {
    await _delay(fetchDelay);
    return List<Todo>.unmodifiable(_todos);
  }

  @override
  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
    required TodoFilter filter,
    required TodoSort sort,
  }) async {
    await _delay(fetchDelay);
    if (offset < 0 || limit <= 0) {
      return <Todo>[];
    }
    final List<Todo> ordered = _fakeInMemoryFilterSort(
      List<Todo>.of(_todos),
      filter,
      sort,
    );
    if (offset >= ordered.length) {
      return <Todo>[];
    }
    final int end = (offset + limit).clamp(0, ordered.length);
    return List<Todo>.unmodifiable(ordered.sublist(offset, end));
  }

  @override
  Future<Todo> addTodo(String title) async {
    await _delay(actionDelay);
    final Todo todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    _emitSnapshot();
    await _persist();
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    await _delay(actionDelay);
    final int index = _todos.indexWhere((Todo t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      _emitSnapshot();
      await _persist();
    }
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _delay(actionDelay);
    _todos.removeWhere((Todo t) => t.id == id);
    _emitSnapshot();
    await _persist();
  }

  void dispose() {
    _controller.close();
  }
}

/// In-memory filter/sort for [FakeFirebaseService] paging only — not a production pattern.
/// A real Firebase/REST API would encode query params and return already-ordered rows.
List<Todo> _fakeInMemoryFilterSort(
  List<Todo> todos,
  TodoFilter filter,
  TodoSort sort,
) {
  Iterable<Todo> items = todos;
  if (filter == TodoFilter.active) {
    items = items.where((Todo e) => !e.isCompleted);
  } else if (filter == TodoFilter.completed) {
    items = items.where((Todo e) => e.isCompleted);
  }
  final List<Todo> list = List<Todo>.of(items);
  if (sort == TodoSort.createdDesc) {
    list.sort((Todo a, Todo b) => b.createdAt.compareTo(a.createdAt));
  } else if (sort == TodoSort.createdAsc) {
    list.sort((Todo a, Todo b) => a.createdAt.compareTo(b.createdAt));
  } else if (sort == TodoSort.titleAsc) {
    list.sort(
      (Todo a, Todo b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
  }
  return list;
}
