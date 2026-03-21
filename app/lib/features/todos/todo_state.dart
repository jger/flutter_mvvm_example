import 'package:app/domain/models/todo.dart';
import 'package:equatable/equatable.dart';

class TodosState extends Equatable {
  const TodosState({required this.todos, this.isLoading = false, this.error});
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  static const Object _unsetError = Object();

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    Object? error = _unsetError,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unsetError) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[todos, isLoading, error];
}
