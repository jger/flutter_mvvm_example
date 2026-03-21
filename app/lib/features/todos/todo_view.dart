import 'package:app/core/theme/theme_mode_provider.dart';
import 'package:app/core/ui/ui_constants.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/features/todos/todo_state.dart';
import 'package:app/features/todos/todo_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TodosState state = ref.watch(todosViewModelProvider);
    final TodosViewModel viewModel = ref.read(todosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('appBarTitle'.tr()),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: 'themeToggleTooltip'.tr(),
            onPressed: () {
              final Brightness platform =
                  MediaQuery.platformBrightnessOf(context);
              ref.read(appThemeModeProvider.notifier).toggle(platform);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) => context.setLocale(locale),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Text('languageEnglish'.tr()),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('de'),
                child: Text('languageGerman'.tr()),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('el'),
                child: Text('languageGreek'.tr()),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: UiConstants.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(UiConstants.spacingMd),
            child: Column(
              children: <Widget>[
                Semantics(
                  label: 'addTodoHint'.tr(),
                  textField: true,
                  child: _TodoInputField(
                    hintText: 'addTodoHint'.tr(),
                    onSubmitted: viewModel.addTodo,
                  ),
                ),
                const SizedBox(height: UiConstants.spacingMd),
                if (state.error != null)
                  Semantics(
                    label: 'errorBannerLabel'.tr(),
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(UiConstants.spacingSm),
                      margin:
                          const EdgeInsets.only(bottom: UiConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius:
                            BorderRadius.circular(UiConstants.radiusSm),
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
                  child: RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: state.isLoading && state.todos.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.35,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ],
                          )
                        : state.todos.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: <Widget>[
                              const SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'emptyState'.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.todos.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Todo todo = state.todos[index];
                              return _TodoItem(
                                todo: todo,
                                onToggle: () => viewModel.toggleTodo(todo),
                                onDelete: () => viewModel.deleteTodo(todo.id),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoInputField extends StatefulWidget {
  const _TodoInputField({required this.hintText, required this.onSubmitted});
  final String hintText;
  final void Function(String) onSubmitted;

  @override
  State<_TodoInputField> createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends State<_TodoInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusSm),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSubmitted(_controller.text);
              _controller.clear();
            }
          },
        ),
      ),
      onSubmitted: (String value) {
        if (value.trim().isNotEmpty) {
          widget.onSubmitted(value);
          _controller.clear();
        }
      },
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: todo.title,
      checked: todo.isCompleted,
      child: Card(
        margin: const EdgeInsets.only(bottom: UiConstants.spacingXs),
        child: ListTile(
          leading: Checkbox(
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
          trailing: IconButton(
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
