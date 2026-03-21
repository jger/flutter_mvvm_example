import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';

/// Thin data layer: maps domain operations to [FirebaseService] (real or fake).
class TodoRepository {
  TodoRepository(this._service);
  final FirebaseService _service;

  Stream<List<Todo>> watchTodos() => _service.watchTodos();

  Future<List<Todo>> getTodos() => _service.getTodos();

  Future<Todo> addTodo(String title) => _service.addTodo(title);

  Future<Todo> updateTodo(Todo todo) => _service.updateTodo(todo);

  Future<void> deleteTodo(String id) => _service.deleteTodo(id);
}
