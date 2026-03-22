import 'dart:async';

import 'package:flutter_mvvm_example/core/logging/app_logger.dart';
import 'package:flutter_mvvm_example/core/logging/app_logger_provider.dart';
import 'package:flutter_mvvm_example/data/repositories/todo_repository.dart';
import 'package:flutter_mvvm_example/domain/models/todo.dart';
import 'package:flutter_mvvm_example/domain/todo_failure.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/todo_providers.dart';
import 'package:flutter_mvvm_example/features/todos/todo_state.dart';
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
      (List<Todo> allTodos) {
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(
          allTodos: allTodos,
          isLoading: false,
          error: null,
        );
        unawaited(_reloadFirstPage());
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
      allTodos: const <Todo>[],
      todos: const <Todo>[],
      isLoading: true,
      filter: initial.filter,
      sort: initial.sort,
    );
  }

  Future<void> _reloadFirstPage() async {
    if (!ref.mounted) {
      return;
    }
    try {
      final List<Todo> first = await _repo.getTodosPage(
        offset: 0,
        limit: state.pageSize,
        filter: state.filter,
        sort: state.sort,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        todos: first,
        hasMore: first.length >= state.pageSize,
        isLoadingMore: false,
      );
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (e, st) {
      _logger.log('reloadFirstPage failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Loads the next page when scrolling near the end.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final List<Todo> next = await _repo.getTodosPage(
        offset: state.todos.length,
        limit: state.pageSize,
        filter: state.filter,
        sort: state.sort,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        todos: <Todo>[...state.todos, ...next],
        hasMore: next.length >= state.pageSize,
        isLoadingMore: false,
      );
    } on TodoFailure catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (e, st) {
      _logger.log('loadMore failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Updates the list filter and reloads the first page.
  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
    unawaited(_saveDisplayPrefs());
    unawaited(_reloadFirstPage());
  }

  /// Updates the sort order and reloads the first page.
  void setSort(TodoSort sort) {
    state = state.copyWith(sort: sort);
    unawaited(_saveDisplayPrefs());
    unawaited(_reloadFirstPage());
  }

  Future<void> _saveDisplayPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todo_filter', state.filter.name);
    await prefs.setString('todo_sort', state.sort.name);
  }

  /// Pull-to-refresh: reloads full list and first page.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      final List<Todo> full = await _repo.getTodos();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(allTodos: full, error: null);
      await _reloadFirstPage();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isRefreshing: false);
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

  /// Adds a todo; ignores blank [title].
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

  /// Toggles completion for [todo].
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

  /// Deletes the todo with [id].
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

  /// Updates a todo title; ignores blank [newTitle].
  Future<void> updateTodoTitle(String id, String newTitle) async {
    final String trimmed = newTitle.trim();
    if (trimmed.isEmpty) {
      return;
    }
    Todo? current;
    for (final Todo t in state.allTodos) {
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

  /// Replays the last failed mutation stored on state.
  Future<void> retryLastFailed() async {
    final TodoOperation? op = state.pendingRetry;
    if (op == null) {
      return;
    }
    state = state.copyWith(pendingRetry: null, error: null);
    switch (op) {
      case TodoAddOp(:final String title):
        await addTodo(title);
      case TodoToggleOp(:final Todo todo):
        await toggleTodo(todo);
      case TodoDeleteOp(:final String id):
        await deleteTodo(id);
      case TodoEditTitleOp(:final String id, :final String newTitle):
        await updateTodoTitle(id, newTitle);
    }
  }

  /// Clears the pending retry flag without retrying.
  void dismissRetry() {
    state = state.copyWith(pendingRetry: null);
  }
}
