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
    required this.allTodos,
    required this.todos,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.filter = TodoFilter.all,
    this.sort = TodoSort.createdDesc,
    this.pendingRetry,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.pageSize = 20,
  });

  /// Full list from the backend stream (authoritative for lookups).
  final List<Todo> allTodos;

  /// Loaded slice(s) from the repository paged query for the current filter/sort.
  final List<Todo> todos;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final TodoFilter filter;
  final TodoSort sort;
  final TodoOperation? pendingRetry;
  final bool hasMore;
  final bool isLoadingMore;
  final int pageSize;

  static const Object _unsetError = Object();

  /// Paged rows for the list (already filtered/sorted by the repository).
  List<Todo> get visibleTodos => todos;

  TodosState copyWith({
    List<Todo>? allTodos,
    List<Todo>? todos,
    bool? isLoading,
    bool? isRefreshing,
    Object? error = _unsetError,
    TodoFilter? filter,
    TodoSort? sort,
    Object? pendingRetry = _unsetError,
    bool? hasMore,
    bool? isLoadingMore,
    int? pageSize,
  }) {
    return TodosState(
      allTodos: allTodos ?? this.allTodos,
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: identical(error, _unsetError) ? this.error : error as String?,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      pendingRetry: identical(pendingRetry, _unsetError)
          ? this.pendingRetry
          : pendingRetry as TodoOperation?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    allTodos,
    todos,
    isLoading,
    isRefreshing,
    error,
    filter,
    sort,
    pendingRetry,
    hasMore,
    isLoadingMore,
    pageSize,
  ];
}
