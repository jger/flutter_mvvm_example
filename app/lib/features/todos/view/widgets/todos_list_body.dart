import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todo_list_row.dart';
import 'package:flutter_mvvm_example/features/todos/viewmodel/todo_state.dart';
import 'package:flutter_mvvm_example/features/todos/viewmodel/todo_view_model.dart';

/// Scrollable todo list with pull-to-refresh, loading and empty states.
class TodosListBody extends StatelessWidget {
  /// Creates the list area.
  const TodosListBody({
    required this.state,
    required this.viewModel,
    required this.scrollController,
    required this.bottomFabInset,
    super.key,
  });

  /// Current VM state.
  final TodosState state;

  /// View model for actions.
  final TodosViewModel viewModel;

  /// List scroll controller (load-more at end).
  final ScrollController scrollController;

  /// Bottom padding so the last item clears the composer.
  final double bottomFabInset;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Semantics(
            label: 'todoListSemanticLabel'.tr(),
            explicitChildNodes: true,
            child: RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: state.isLoading && state.allTodos.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomFabInset),
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.35,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    )
                  : state.visibleTodos.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomFabInset),
                      children: <Widget>[
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            state.allTodos.isEmpty
                                ? 'emptyState'.tr()
                                : 'emptyFilteredState'.tr(),
                            key: state.allTodos.isEmpty
                                ? const Key('empty_state_message')
                                : const Key('empty_filtered_message'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomFabInset),
                      itemCount:
                          state.visibleTodos.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= state.visibleTodos.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final Todo todo = state.visibleTodos[index];
                        return TodoListRow(
                          todo: todo,
                          onToggle: () => viewModel.toggleTodo(todo),
                          onDelete: () => viewModel.deleteTodo(todo.id),
                          onEditTitle: (String newTitle) =>
                              viewModel.updateTodoTitle(todo.id, newTitle),
                        );
                      },
                    ),
            ),
          ),
          if (state.isRefreshing)
            const Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
