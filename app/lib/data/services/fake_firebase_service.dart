import 'dart:async';
import 'package:app/domain/models/todo.dart';

abstract class FirebaseService {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(String title);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}

class FakeFirebaseService implements FirebaseService {

  FakeFirebaseService() {
    _todos.addAll([
      Todo(
        id: '1',
        title: 'Learn MVVM Architecture',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Todo(
        id: '2',
        title: 'Build Todo App',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
    _controller.add(_todos);
  }
  final List<Todo> _todos = [];
  final _controller = StreamController<List<Todo>>.broadcast();

  Stream<List<Todo>> watchTodos() => _controller.stream;

  @override
  Future<List<Todo>> getTodos() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_todos);
  }

  @override
  Future<Todo> addTodo(String title) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    _controller.add(List.unmodifiable(_todos));
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      _controller.add(List.unmodifiable(_todos));
    }
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _todos.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_todos));
  }

  void dispose() {
    _controller.close();
  }
}
