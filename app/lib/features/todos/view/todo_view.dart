import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo_filters.dart';
import 'package:flutter_mvvm_example/features/todos/view/floating_todo_composer.dart';
import 'package:flutter_mvvm_example/features/todos/viewmodel/todo_state.dart';
import 'package:flutter_mvvm_example/features/todos/viewmodel/todo_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Main todo list screen with composer and settings entry.
class TodosPage extends HookConsumerWidget {
  /// Creates the todos page.
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String?> lastSnackError = useState<String?>(null);
    final ScrollController scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) {
          return;
        }
        final TodosState state = ref.read(todosViewModelProvider);
        if (state.isLoadingMore || !state.hasMore) {
          return;
        }
        final double max = scrollController.position.maxScrollExtent;
        if (max <= 0) {
          return;
        }
        if (scrollController.position.pixels >=
            max - UiConstants.todoListLoadMoreThreshold) {
          ref.read(todosViewModelProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, <Object?>[scrollController]);

    final TodosState state = ref.watch(todosViewModelProvider);
    final TodosViewModel viewModel = ref.read(todosViewModelProvider.notifier);

    ref.listen<TodosState>(todosViewModelProvider, (
      TodosState? previous,
      TodosState next,
    ) {
      if (next.error != null &&
          next.pendingRetry != null &&
          next.error != lastSnackError.value) {
        lastSnackError.value = next.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            action: SnackBarAction(
              label: 'retryAction'.tr(),
              onPressed: viewModel.retryLastFailed,
            ),
          ),
        );
      }
      if (next.error == null && next.pendingRetry == null) {
        lastSnackError.value = null;
      }
    });

    final double bottomFabInset =
        MediaQuery.paddingOf(context).bottom +
        kComposerBottomReserve +
        32 +
        2 * kComposerGlowMargin;

    return Scaffold(
      appBar: AppBar(
        title: Text('appBarTitle'.tr()),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: 'configTooltip'.tr(),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/config'),
          ),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: UiConstants.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _FilterSortBar(
                        filter: state.filter,
                        sort: state.sort,
                        onFilterChanged: viewModel.setFilter,
                        onSortChanged: viewModel.setSort,
                      ),
                      const SizedBox(height: UiConstants.spacingMd),
                      if (state.error != null)
                        Semantics(
                          label: 'errorBannerLabel'.tr(),
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(
                              UiConstants.spacingSm,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: UiConstants.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusSm,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.error,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: UiConstants.spacingXs),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Semantics(
                              label: 'todoListSemanticLabel'.tr(),
                              explicitChildNodes: true,
                              child: RefreshIndicator(
                                onRefresh: viewModel.refresh,
                                child: state.isLoading && state.allTodos.isEmpty
                                    ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(
                                          bottom: bottomFabInset,
                                        ),
                                        children: <Widget>[
                                          SizedBox(
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.35,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ],
                                      )
                                    : state.visibleTodos.isEmpty
                                    ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(
                                          bottom: bottomFabInset,
                                        ),
                                        children: <Widget>[
                                          const SizedBox(height: 120),
                                          Center(
                                            child: Text(
                                              state.allTodos.isEmpty
                                                  ? 'emptyState'.tr()
                                                  : 'emptyFilteredState'.tr(),
                                              key: state.allTodos.isEmpty
                                                  ? const Key(
                                                      'empty_state_message',
                                                    )
                                                  : const Key(
                                                      'empty_filtered_message',
                                                    ),
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
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(
                                          bottom: bottomFabInset,
                                        ),
                                        itemCount:
                                            state.visibleTodos.length +
                                            (state.isLoadingMore ? 1 : 0),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                              if (index >=
                                                  state.visibleTodos.length) {
                                                return const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }
                                              final Todo todo =
                                                  state.visibleTodos[index];
                                              return _TodoItem(
                                                todo: todo,
                                                onToggle: () =>
                                                    viewModel.toggleTodo(todo),
                                                onDelete: () => viewModel
                                                    .deleteTodo(todo.id),
                                                onEditTitle:
                                                    (String newTitle) =>
                                                        viewModel
                                                            .updateTodoTitle(
                                                              todo.id,
                                                              newTitle,
                                                            ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: UiConstants.spacingXs,
            right: UiConstants.spacingXs,
            bottom:
                MediaQuery.paddingOf(context).bottom +
                UiConstants.spacingMd +
                kComposerGlowMargin,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                4,
                kComposerGlowMargin,
                4,
                kComposerGlowMargin,
              ),
              child: Center(
                child: FloatingTodoComposer(
                  hintText: 'addTodoHint'.tr(),
                  onSubmitted: viewModel.addTodo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSortBar extends StatelessWidget {
  const _FilterSortBar({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });
  final TodoFilter filter;
  final TodoSort sort;
  final void Function(TodoFilter) onFilterChanged;
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

class _TodoItem extends StatelessWidget {
  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEditTitle,
  });
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Future<void> Function(String newTitle) onEditTitle;

  Future<void> _showEditDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return HookBuilder(
          builder: (BuildContext context) {
            final TextEditingController controller = useTextEditingController(
              text: todo.title,
            );
            return AlertDialog(
              title: Text('editTodoTitle'.tr()),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(labelText: 'todoTitleLabel'.tr()),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('cancel'.tr()),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: Text('save'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null && result.trim().isNotEmpty) {
      await onEditTitle(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: todo.title,
      checked: todo.isCompleted,
      child: Card(
        margin: const EdgeInsets.only(bottom: UiConstants.spacingXs),
        child: ListTile(
          leading: Checkbox(
            key: ValueKey<String>('todo_checkbox_${todo.id}'),
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          onTap: () => _showEditDialog(context),
          trailing: IconButton(
            key: ValueKey<String>('todo_delete_${todo.id}'),
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
