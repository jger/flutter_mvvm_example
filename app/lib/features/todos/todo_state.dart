import '../../domain/models/todo.dart';

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







