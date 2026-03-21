import 'package:app/features/todos/todo_state.dart';
import 'package:app/features/todos/todo_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TodosViewModel loads todos from stream', () async {
    final ProviderContainer container = ProviderContainer();
    final ProviderSubscription<TodosState> sub = container.listen<TodosState>(
      todosViewModelProvider,
      (TodosState? previous, TodosState next) {},
    );
    addTearDown(sub.close);
    addTearDown(container.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final TodosState state = container.read(todosViewModelProvider);
    expect(state.todos.length, greaterThan(0));
    expect(state.isLoading, isFalse);
  });
}
