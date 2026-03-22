import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';
import 'package:flutter_mvvm_example/features/todos/view/floating_todo_composer.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/composer_constants.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todo_error_banner.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todo_filter_sort_bar.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todos_list_body.dart';
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
                      TodoFilterSortBar(
                        filter: state.filter,
                        sort: state.sort,
                        onFilterChanged: viewModel.setFilter,
                        onSortChanged: viewModel.setSort,
                      ),
                      const SizedBox(height: UiConstants.spacingMd),
                      if (state.error != null)
                        TodoErrorBanner(message: state.error!),
                      TodosListBody(
                        state: state,
                        viewModel: viewModel,
                        scrollController: scrollController,
                        bottomFabInset: bottomFabInset,
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
