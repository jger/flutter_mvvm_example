import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo.dart';

/// One todo row: checkbox, title, delete; tap opens edit title dialog.
class TodoListRow extends StatelessWidget {
  /// Creates a row for [todo].
  const TodoListRow({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEditTitle,
    super.key,
  });

  /// Entry ([Todo]) shown in this row.
  final Todo todo;

  /// Toggle completion.
  final VoidCallback onToggle;

  /// Delete this todo.
  final VoidCallback onDelete;

  /// Persist new title from the edit dialog.
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
