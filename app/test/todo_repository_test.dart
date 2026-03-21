import 'package:app/data/repositories/todo_repository.dart';
import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TodoRepository getTodos and mutations', () async {
    final FakeFirebaseService service = FakeFirebaseService();
    final TodoRepository repo = TodoRepository(service);
    expect((await repo.getTodos()).length, 2);
    await repo.addTodo('third');
    expect((await repo.getTodos()).length, 3);
    service.dispose();
  });

  test('watchTodos emits on add', () async {
    final FakeFirebaseService service = FakeFirebaseService();
    final TodoRepository repo = TodoRepository(service);
    final Future<List<Todo>> next = repo.watchTodos().first;
    await repo.addTodo('x');
    expect((await next).length, 3);
    service.dispose();
  });
}
