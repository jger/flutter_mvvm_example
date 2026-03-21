import 'package:app/features/settings/config_view.dart';
import 'package:app/features/todos/todo_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
