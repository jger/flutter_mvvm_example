import 'dart:async';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/logging/app_logger_provider.dart';
import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_failure.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:app/features/todos/todo_providers.dart';
import 'package:app/features/todos/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'todo_view_model.g.dart';

/// ViewModel manages state and business logic (MVVM + Riverpod 3).
@riverpod
class TodosViewModel extends _$TodosViewModel {
  late TodoRepository _repo;
  late AppLogger _logger;
  StreamSubscription<List<Todo>>? _sub;

  @override
  TodosState build() {
    final TodoInitialUi initial = ref.watch(todoInitialUiProvider);
    _repo = ref.watch(todoRepositoryProvider);
    _logger = ref.watch(appLoggerProvider);
    _sub?.cancel();
    _sub = _repo.watchTodos().listen(
      (List<Todo> todos) {
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(todos: todos, isLoading: false, error: null);
      },
      onError: (Object e, StackTrace st) {
        _logger.log('watchTodos error', error: e, stackTrace: st);
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
    ref.onDispose(() {
      final StreamSubscription<List<Todo>>? previous = _sub;
      _sub = null;
      previous?.cancel();
    });
    return TodosState(
      todos: const <Todo>[],
      isLoading: true,
      filter: initial.filter,
      sort: initial.sort,
    );
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
    unawaited(_saveDisplayPrefs());
  }

  void setSort(TodoSort sort) {
    state = state.copyWith(sort: sort);
    unawaited(_saveDisplayPrefs());
  }

  Future<void> _saveDisplayPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todo_filter', state.filter.name);
    await prefs.setString('todo_sort', state.sort.name);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      final List<Todo> todos = await _repo.getTodos();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(todos: todos, isRefreshing: false, error: null);
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isRefreshing: false, error: e.message);
    } catch (e, st) {
      _logger.log('refresh failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) {
      return;
    }
    final String trimmed = title.trim();
    try {
      await _repo.addTodo(trimmed);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(pendingRetry: null);
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.message,
        pendingRetry: TodoAddOp(trimmed),
      );
    } catch (e, st) {
      _logger.log('addTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.toString(),
        pendingRetry: TodoAddOp(trimmed),
      );
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    try {
      final Todo updated = todo.copyWith(isCompleted: !todo.isCompleted);
      await _repo.updateTodo(updated);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(pendingRetry: null);
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.message,
        pendingRetry: TodoToggleOp(todo),
      );
    } catch (e, st) {
      _logger.log('updateTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.toString(),
        pendingRetry: TodoToggleOp(todo),
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _repo.deleteTodo(id);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(pendingRetry: null);
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(error: e.message, pendingRetry: TodoDeleteOp(id));
    } catch (e, st) {
      _logger.log('deleteTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.toString(),
        pendingRetry: TodoDeleteOp(id),
      );
    }
  }

  Future<void> updateTodoTitle(String id, String newTitle) async {
    final String trimmed = newTitle.trim();
    if (trimmed.isEmpty) {
      return;
    }
    Todo? current;
    for (final Todo t in state.todos) {
      if (t.id == id) {
        current = t;
        break;
      }
    }
    if (current == null) {
      return;
    }
    try {
      await _repo.updateTodo(current.copyWith(title: trimmed));
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(pendingRetry: null);
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.message,
        pendingRetry: TodoEditTitleOp(id: id, newTitle: trimmed),
      );
    } catch (e, st) {
      _logger.log('updateTodoTitle failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        error: e.toString(),
        pendingRetry: TodoEditTitleOp(id: id, newTitle: trimmed),
      );
    }
  }

  Future<void> retryLastFailed() async {
    final TodoOperation? op = state.pendingRetry;
    if (op == null) {
      return;
    }
    state = state.copyWith(pendingRetry: null, error: null);
    switch (op) {
      case TodoAddOp(:final title):
        await addTodo(title);
      case TodoToggleOp(:final todo):
        await toggleTodo(todo);
      case TodoDeleteOp(:final id):
        await deleteTodo(id);
      case TodoEditTitleOp(:final id, :final newTitle):
        await updateTodoTitle(id, newTitle);
    }
  }

  void dismissRetry() {
    state = state.copyWith(pendingRetry: null);
  }
}
