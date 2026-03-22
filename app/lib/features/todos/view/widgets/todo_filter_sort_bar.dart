import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo_filters.dart';

/// Filter segments and sort menu for the todos list.
class TodoFilterSortBar extends StatelessWidget {
  /// Creates the filter/sort bar.
  const TodoFilterSortBar({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
    super.key,
  });

  /// Current filter.
  final TodoFilter filter;

  /// Current sort.
  final TodoSort sort;

  /// Called when the user changes the filter.
  final void Function(TodoFilter) onFilterChanged;

  /// Called when the user changes the sort order.
  final void Function(TodoSort) onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SegmentedButton<TodoFilter>(
            segments: <ButtonSegment<TodoFilter>>[
              ButtonSegment<TodoFilter>(
                value: TodoFilter.all,
                label: Text('filterAll'.tr()),
              ),
              ButtonSegment<TodoFilter>(
                value: TodoFilter.active,
                label: Text('filterActive'.tr()),
              ),
              ButtonSegment<TodoFilter>(
                value: TodoFilter.completed,
                label: Text('filterCompleted'.tr()),
              ),
            ],
            selected: <TodoFilter>{filter},
            onSelectionChanged: (Set<TodoFilter> next) {
              onFilterChanged(next.first);
            },
          ),
        ),
        const SizedBox(width: UiConstants.spacingSm),
        PopupMenuButton<TodoSort>(
          tooltip: 'sortTooltip'.tr(),
          onSelected: onSortChanged,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<TodoSort>>[
            CheckedPopupMenuItem<TodoSort>(
              value: TodoSort.createdDesc,
              checked: sort == TodoSort.createdDesc,
              child: Text('sortNewest'.tr()),
            ),
            CheckedPopupMenuItem<TodoSort>(
              value: TodoSort.createdAsc,
              checked: sort == TodoSort.createdAsc,
              child: Text('sortOldest'.tr()),
            ),
            CheckedPopupMenuItem<TodoSort>(
              value: TodoSort.titleAsc,
              checked: sort == TodoSort.titleAsc,
              child: Text('sortTitle'.tr()),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.sort_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
