import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/todo.dart';
import 'todo_view_model.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todosViewModelProvider);
    final viewModel = ref.read(todosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _TodoInputField(
                  onSubmitted: (title) => viewModel.addTodo(title),
                ),
                const SizedBox(height: 16),
                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.todos.isEmpty
                          ? const Center(
                              child: Text(
                                'No todos yet. Add one above!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.todos.length,
                              itemBuilder: (context, index) {
                                final todo = state.todos[index];
                                return _TodoItem(
                                  todo: todo,
                                  onToggle: () => viewModel.toggleTodo(todo),
                                  onDelete: () => viewModel.deleteTodo(todo.id),
                                );
                              },
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
  final void Function(String) onSubmitted;

  const _TodoInputField({required this.onSubmitted});

  @override
  State<_TodoInputField> createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends State<_TodoInputField> {
  final _controller = TextEditingController();

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
        hintText: 'Add a new todo...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          widget.onSubmitted(value);
          _controller.clear();
        }
      },
    );
  }
}

class _TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
