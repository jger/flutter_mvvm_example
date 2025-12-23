import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/todo.dart';
import '../../data/services/fake_firebase_service.dart';

final firebaseServiceProvider = Provider<FakeFirebaseService>((ref) {
  final service = FakeFirebaseService();
  ref.onDispose(() => service.dispose());
  return service;
});

final todosViewModelProvider =
    NotifierProvider<TodosViewModel, TodosState>(TodosViewModel.new);

class TodosState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodosState({
    required this.todos,
    this.isLoading = false,
    this.error,
  });

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TodosViewModel extends Notifier<TodosState> {
  late final FirebaseService _service;

  @override
  TodosState build() {
    _service = ref.read(firebaseServiceProvider);
    _loadTodos();
    return TodosState(todos: const []);
  }

  Future<void> _loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
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
