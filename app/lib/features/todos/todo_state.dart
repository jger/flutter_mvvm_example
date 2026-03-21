import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:equatable/equatable.dart';

/// Last failed mutation for snackbar retry.
sealed class TodoOperation extends Equatable {
  const TodoOperation();

  @override
  List<Object?> get props => <Object?>[];
}

final class TodoAddOp extends TodoOperation {
  const TodoAddOp(this.title);
  final String title;

  @override
  List<Object?> get props => <Object?>[title];
}

final class TodoToggleOp extends TodoOperation {
  const TodoToggleOp(this.todo);
  final Todo todo;

  @override
  List<Object?> get props => <Object?>[todo];
}

final class TodoDeleteOp extends TodoOperation {
  const TodoDeleteOp(this.id);
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

final class TodoEditTitleOp extends TodoOperation {
  const TodoEditTitleOp({required this.id, required this.newTitle});
  final String id;
  final String newTitle;

  @override
  List<Object?> get props => <Object?>[id, newTitle];
}

class TodosState extends Equatable {
  const TodosState({
    required this.todos,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.filter = TodoFilter.all,
    this.sort = TodoSort.createdDesc,
    this.pendingRetry,
  });
  final List<Todo> todos;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final TodoFilter filter;
  final TodoSort sort;
  final TodoOperation? pendingRetry;

  static const Object _unsetError = Object();

  List<Todo> get visibleTodos {
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

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    bool? isRefreshing,
    Object? error = _unsetError,
    TodoFilter? filter,
    TodoSort? sort,
    Object? pendingRetry = _unsetError,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: identical(error, _unsetError)
          ? this.error
          : error as String?,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      pendingRetry: identical(pendingRetry, _unsetError)
          ? this.pendingRetry
          : pendingRetry as TodoOperation?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    todos,
    isLoading,
    isRefreshing,
    error,
    filter,
    sort,
    pendingRetry,
  ];
}
