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

  test('getTodosPage returns slice', () async {
    final FakeFirebaseService service = FakeFirebaseService(
      actionDelay: Duration.zero,
      fetchDelay: Duration.zero,
    );
    final TodoRepository repo = TodoRepository(service);
    expect((await repo.getTodosPage(offset: 0, limit: 1)).length, 1);
    expect((await repo.getTodosPage(offset: 2, limit: 5)).length, 0);
    service.dispose();
  });

  test('watchTodos emits on add', () async {
    final FakeFirebaseService service = FakeFirebaseService();
    final TodoRepository repo = TodoRepository(service);
    final Future<List<Todo>> afterAdd = repo.watchTodos().skip(1).first;
    await repo.addTodo('x');
    expect((await afterAdd).length, 3);
    service.dispose();
  });
}
