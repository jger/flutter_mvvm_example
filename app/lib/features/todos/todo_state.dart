import 'package:app/domain/models/todo.dart';

class TodosState {

  TodosState({
    required this.todos,
    this.isLoading = false,
    this.error,
  });
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

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
