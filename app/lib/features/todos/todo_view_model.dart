import 'dart:async';
import 'dart:developer' as developer;

import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/features/todos/todo_providers.dart';
import 'package:app/features/todos/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_view_model.g.dart';

/// ViewModel manages state and business logic
/// Extends Notifier following MVVM pattern (Riverpod 3.x)
@riverpod
class TodosViewModel extends _$TodosViewModel {
  late TodoRepository _repo;
  StreamSubscription<List<Todo>>? _sub;

  @override
  TodosState build() {
    _repo = ref.watch(todoRepositoryProvider);
    _sub?.cancel();
    _sub = _repo.watchTodos().listen(
      (List<Todo> todos) {
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(todos: todos, isLoading: false, error: null);
      },
      onError: (Object e, StackTrace st) {
        developer.log('watchTodos error', error: e, stackTrace: st);
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
    // Broadcast stream replays no seed; initial list comes from getTodos once.
    Future.microtask(_loadTodos);
    return const TodosState(todos: [], isLoading: true);
  }

  Future<void> _loadTodos({bool showFullScreenLoading = true}) async {
    if (showFullScreenLoading) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final List<Todo> todos = await _repo.getTodos();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(todos: todos, isLoading: false, error: null);
    } catch (e, st) {
      developer.log('getTodos failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _loadTodos(showFullScreenLoading: false);

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) {
      return;
    }
    try {
      await _repo.addTodo(title.trim());
    } catch (e, st) {
      developer.log('addTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    try {
      final Todo updated = todo.copyWith(isCompleted: !todo.isCompleted);
      await _repo.updateTodo(updated);
    } catch (e, st) {
      developer.log('updateTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _repo.deleteTodo(id);
    } catch (e, st) {
      developer.log('deleteTodo failed', error: e, stackTrace: st);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(error: e.toString());
    }
  }
}
