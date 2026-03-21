import 'package:equatable/equatable.dart';

enum TodoFilter { all, active, completed }

enum TodoSort { createdDesc, createdAsc, titleAsc }

/// Initial filter/sort from SharedPreferences (overridable in tests / main).
class TodoInitialUi extends Equatable {
  const TodoInitialUi({required this.filter, required this.sort});
  final TodoFilter filter;
  final TodoSort sort;

  static const TodoInitialUi defaults = TodoInitialUi(
    filter: TodoFilter.all,
    sort: TodoSort.createdDesc,
  );

  @override
  List<Object?> get props => <Object?>[filter, sort];
}
