import 'package:flutter_mvvm_example/domain/models/todo.dart';
import 'package:flutter_mvvm_example/features/todos/todo_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodosState.copyWith', () {
    final Todo t = Todo(
      id: 'a',
      title: 'x',
      isCompleted: false,
      createdAt: DateTime(2024),
    );
    final TodosState base = TodosState(
      allTodos: <Todo>[t],
      todos: <Todo>[t],
      error: 'old',
    );

    test('preserves error when omitted', () {
      final TodosState next = base.copyWith(isLoading: true);
      expect(next.error, 'old');
    });

    test('clears error when null passed', () {
      final TodosState next = base.copyWith(error: null);
      expect(next.error, isNull);
    });

    test('replaces error when string passed', () {
      final TodosState next = base.copyWith(error: 'new');
      expect(next.error, 'new');
    });
  });
}
