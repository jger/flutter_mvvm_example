import 'dart:convert';

import 'package:flutter_mvvm_example/domain/models/todo.dart';
import 'package:flutter_mvvm_example/domain/todo_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKeyTodosJson = 'todos_json_v1';

/// Loads and saves the todo list for app restarts (single source with FakeFirebaseService).
class TodoPersistence {
  TodoPersistence._();

  /// Returns persisted todos, or null if missing or invalid JSON.
  static List<Todo>? load(SharedPreferences prefs) {
    final String? raw = prefs.getString(_prefsKeyTodosJson);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((dynamic e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object {
      return null;
    }
  }

  /// Writes [todos] to [prefs] as JSON.
  static Future<void> save(SharedPreferences prefs, List<Todo> todos) async {
    final String raw = jsonEncode(todos.map((Todo t) => t.toJson()).toList());
    await prefs.setString(_prefsKeyTodosJson, raw);
  }

  /// Loads saved filter/sort for the todo list UI.
  static TodoInitialUi loadInitialUi(SharedPreferences prefs) {
    final String? f = prefs.getString('todo_filter');
    final String? s = prefs.getString('todo_sort');
    final TodoFilter filter =
        _enumByName(TodoFilter.values, f) ?? TodoFilter.all;
    final TodoSort sort =
        _enumByName(TodoSort.values, s) ?? TodoSort.createdDesc;
    return TodoInitialUi(filter: filter, sort: sort);
  }

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) {
      return null;
    }
    for (final T v in values) {
      if (v.name == name) {
        return v;
      }
    }
    return null;
  }
}
