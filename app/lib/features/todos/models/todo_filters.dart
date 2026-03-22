import 'package:equatable/equatable.dart';

/// Which todos to show in the list.
enum TodoFilter {
  /// Every todo.
  all,

  /// Only incomplete.
  active,

  /// Only complete.
  completed,
}

/// Sort order for the todo list.
enum TodoSort {
  /// Newest first by creation time (`createdAt` field).
  createdDesc,

  /// Oldest first by creation time (`createdAt` field).
  createdAsc,

  /// Alphabetical by title (case-insensitive).
  titleAsc,
}

/// Initial filter/sort from SharedPreferences (overridable in tests / main).
class TodoInitialUi extends Equatable {
  /// Creates initial UI prefs.
  const TodoInitialUi({required this.filter, required this.sort});

  /// Current filter chip selection.
  final TodoFilter filter;

  /// Current sort mode.
  final TodoSort sort;

  /// Default filter/sort at first launch.
  static const TodoInitialUi defaults = TodoInitialUi(
    filter: TodoFilter.all,
    sort: TodoSort.createdDesc,
  );

  @override
  List<Object?> get props => <Object?>[filter, sort];
}
