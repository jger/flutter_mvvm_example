import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/features/settings/view/config_view.dart';
import 'package:flutter_mvvm_example/features/todos/view/todo_view.dart';
import 'package:go_router/go_router.dart';

/// Builds the root [GoRouter] (todos home and config routes).
GoRouter createAppRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const TodosPage(),
      ),
      GoRoute(
        path: '/config',
        builder: (BuildContext context, GoRouterState state) =>
            const ConfigPage(),
      ),
    ],
  );
}
