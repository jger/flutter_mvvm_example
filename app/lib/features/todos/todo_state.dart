import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_filters.dart';
import 'package:equatable/equatable.dart';

/// Last failed mutation for snackbar retry.
sealed class TodoOperation extends Equatable {
  const TodoOperation();

  @override
  List<Object?> get props => <Object?>[];
}

/// Pending retry for a failed add with this [title].
final class TodoAddOp extends TodoOperation {
  /// Creates a pending add retry.
  const TodoAddOp(this.title);

  /// Title text to resubmit.
  final String title;

  @override
  List<Object?> get props => <Object?>[title];
}

/// Pending retry for a failed completion toggle on [todo].
final class TodoToggleOp extends TodoOperation {
  /// Creates a pending toggle retry.
  const TodoToggleOp(this.todo);

  /// Domain item state before retry.
  final Todo todo;

  @override
  List<Object?> get props => <Object?>[todo];
}

/// Pending retry for a failed delete of todo [id].
final class TodoDeleteOp extends TodoOperation {
  /// Creates a pending delete retry.
  const TodoDeleteOp(this.id);

  /// Target item id.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Pending retry for a failed title edit.
final class TodoEditTitleOp extends TodoOperation {
  /// Creates a pending title-edit retry.
  const TodoEditTitleOp({required this.id, required this.newTitle});

  /// Item id to update.
  final String id;

  /// New title text.
  final String newTitle;

  @override
  List<Object?> get props => <Object?>[id, newTitle];
}

/// View state for the todo list (paging, errors, retry).
class TodosState extends Equatable {
  /// Creates state for the todos screen.
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
  /// Initial full load in progress.
  final bool isLoading;

  /// Pull-to-refresh in progress.
  final bool isRefreshing;

  /// Last error message, if any.
  final String? error;

  /// Active list filter.
  final TodoFilter filter;

  /// Active sort order.
  final TodoSort sort;

  /// Operation to retry after a transient failure.
  final TodoOperation? pendingRetry;

  /// Whether more pages can be loaded.
  final bool hasMore;

  /// Next page fetch in progress.
  final bool isLoadingMore;
  
  /// Page size for repository paged loads.
  final int pageSize;

  static const Object _unsetError = Object();

  /// Paged rows for the list (already filtered/sorted by the repository).
  List<Todo> get visibleTodos => todos;

  /// Returns a copy with optional fields replaced.
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
