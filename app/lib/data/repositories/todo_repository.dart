import 'package:app/data/services/fake_firebase_service.dart';
import 'package:app/domain/models/todo.dart';
import 'package:app/domain/todo_failure.dart';

/// Maps domain operations to [FirebaseService] (real or fake) with typed failures.
class TodoRepository {
  TodoRepository(this._service);
  final FirebaseService _service;

  Stream<List<Todo>> watchTodos() => _service.watchTodos();

  Future<List<Todo>> getTodos() async {
    try {
      return await _service.getTodos();
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
  }) async {
    try {
      return await _service.getTodosPage(offset: offset, limit: limit);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  Future<Todo> addTodo(String title) async {
    try {
      return await _service.addTodo(title);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    try {
      return await _service.updateTodo(todo);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }
}
