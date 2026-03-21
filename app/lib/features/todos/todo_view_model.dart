import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/features/todos/todo_providers.dart';
import 'package:app/features/todos/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_view_model.g.dart';

/// ViewModel manages state and business logic
/// Extends Notifier following MVVM pattern (Riverpod 3.x)
@riverpod
class TodosViewModel extends _$TodosViewModel {
  late FirebaseService _service;

  @override
  TodosState build() {
    // watch hält firebaseServiceProvider am Leben (read + autoDispose → dispose → Stream geschlossen)
    _service = ref.watch(firebaseServiceProvider);
    Future.microtask(_loadTodos);
    return TodosState(todos: [], isLoading: true);
  }

  Future<void> _loadTodos({bool showFullScreenLoading = true}) async {
    if (showFullScreenLoading) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final todos = await _service.getTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => _loadTodos(showFullScreenLoading: false);

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    try {
      await _service.addTodo(title.trim());
      await _loadTodos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    try {
      final updated = todo.copyWith(isCompleted: !todo.isCompleted);
      await _service.updateTodo(updated);
      await _loadTodos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
      await _loadTodos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
