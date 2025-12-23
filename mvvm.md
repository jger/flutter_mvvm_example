## MVVM in this Flutter example

### Roles

- **Model**: Pure data + business objects (no Flutter imports). In this app: domain models like `Todo` plus the fake backend entities in `FakeFirebaseService`.
- **View**: Widgets that render UI and forward user intent to the ViewModel. In this app: `TodosPage` in `features/todos/todo_view.dart`.
- **ViewModel**: Holds immutable view state and exposes commands; no `BuildContext`, no direct widget code. In this app: `TodosViewModel` in `features/todos/todo_view_model.dart` with `TodosState`.

### Data flow

1. **User interacts with View** (e.g. type text, tap “Add”, toggle checkbox).
2. View calls **ViewModel methods** (`addTodo`, `toggleTodo`).
3. ViewModel talks to **services/repositories** (`FakeFirebaseService`) and updates its state.
4. **Riverpod providers** expose ViewModel state; the View rebuilds when state changes.

### Best-practice notes (Flutter/web)

- **Separation**: ViewModel never imports `package:flutter/material.dart`; keep it platform-agnostic.
- **Testability**: ViewModel logic depends on abstractions (`FakeFirebaseService` via provider), so it can be tested without Flutter widgets.
- **Web UX**: Use centered, constrained layouts and Material 3; avoid assuming mobile-only sizes.
- **Replaceable backend**: Swap `FakeFirebaseService` with real Firebase (Auth/Firestore) behind same interface without touching View or ViewModel APIs.


