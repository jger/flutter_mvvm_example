import 'package:flutter_mvvm_example/features/todos/data/services/fake_firebase_service.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo_failure.dart';
import 'package:flutter_mvvm_example/features/todos/models/todo_filters.dart';

/// Maps domain operations to [FirebaseService] (real or fake) with typed failures.
class TodoRepository {
  /// Creates a repository using [FirebaseService] for data access.
  TodoRepository(this._service);
  final FirebaseService _service;

  /// Live stream of all todos from the backend layer.
  Stream<List<Todo>> watchTodos() => _service.watchTodos();

  /// Fetches the full todo list (non-paged).
  Future<List<Todo>> getTodos() async {
    try {
      return await _service.getTodos();
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  /// Returns a page of todos with [filter] and [sort] applied.
  Future<List<Todo>> getTodosPage({
    required int offset,
    required int limit,
    required TodoFilter filter,
    required TodoSort sort,
  }) async {
    try {
      return await _service.getTodosPage(
        offset: offset,
        limit: limit,
        filter: filter,
        sort: sort,
      );
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  /// Adds a new todo with [title].
  Future<Todo> addTodo(String title) async {
    try {
      return await _service.addTodo(title);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  /// Replaces [todo] in storage.
  Future<Todo> updateTodo(Todo todo) async {
    try {
      return await _service.updateTodo(todo);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }

  /// Deletes the todo with [id].
  Future<void> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
    } on Object catch (e) {
      throw TodoFailureUnknown(e.toString());
    }
  }
}
