# Flutter MVVM example

Sample app that demonstrates **MVVM with Riverpod**, a **fake backend** (Firebase-shaped API), and a clear split between **data**, **domain**, and **features**. Use it as a reference for layering, typed errors, and testable view models—not as production infrastructure.

## What you get

| Area | Details |
|------|---------|
| **State & UI** | `flutter_riverpod` (`@riverpod`), view models per feature, Material 3, light/dark (system) |
| **Data** | `FakeFirebaseService` (delays, optional paging, `watchTodos` seed) + `TodoRepository` |
| **Persistence** | JSON via `TodoPersistence` / `SharedPreferences`, wired in `main()` with provider overrides |
| **Navigation** | `go_router`: `/` (todos), `/config` (settings) |
| **i18n** | easy_localization — EN / DE / EL |
| **Logging** | `AppLogger` in `core/logging` |

Todos: filter, sort, edit title (dialog), pull-to-refresh, max content width on web.

## Architecture

- **`domain`**: `Todo`, `TodoFilter` / `TodoSort`, **`TodoFailure`** (sealed domain errors).
- **`data`**: `FakeFirebaseService` + **`TodoRepository`** — maps the backend to streams/futures and surfaces failures as `TodoFailure`.
- **`features`**: `todo_state`, `TodosViewModel`, `TodosPage`, providers; settings under `features/settings`.
- **`core`**: `AppLogger`, `createAppRouter()`.

Flow: **View → ViewModel → Repository → Service**. The UI does not talk to the fake Firebase directly.

## Error handling

Failures are modeled in the domain and handled in one place per operation:

1. **`TodoFailure`** (`todo_failure.dart`) — sealed class with variants such as `TodoFailureUnknown` and `TodoFailureNotFound`, each carrying a **`message`** for the UI.
2. **`TodoRepository`** wraps service calls: unexpected exceptions are converted to **`TodoFailureUnknown`** (or typed failures where the service throws them), so callers see a single error type from the data layer.
3. **`TodosViewModel`**:
   - **`on TodoFailure`**: sets `state.error` to **`e.message`** and, for mutating actions, stores **`pendingRetry`** (`TodoAddOp`, `TodoToggleOp`, etc.) so the user can retry the same operation.
   - **Other errors**: logs with **`AppLogger`**, exposes **`e.toString()`** (or message) on state, and still sets **`pendingRetry`** where applicable.
   - **`watchTodos` stream**: `onError` logs, then sets **`error`** on state (stream errors are not always `TodoFailure`).
4. **UI**: shows errors (e.g. snackbar) and offers **retry** when `pendingRetry` is set; **`retryLastFailed`** / **`dismissRetry`** on the view model drive that.

So: **typed domain errors at the repository boundary**, **user-visible text from `TodoFailure.message`**, **unexpected issues logged**, and **retry** for failed writes without re-entering data.

## Getting started

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

After changing `@riverpod` providers, regenerate code (same `build_runner` command).

## Tests & quality

```bash
flutter test --coverage
flutter analyze
```

- **Unit / VM tests**: view models with `ProviderScope` overrides (e.g. fake service with zero delay).
- **Widget tests**: `MaterialApp(home: TodosPage)` and interaction tests.
- **Golden tests** (opt-in tag `golden`): baseline PNGs under `test/goldens/`. Fonts load via `test/flutter_test_config.dart` and `golden_toolkit` so text does not render as tofu.

**Run goldens** (compare to committed images):

```bash
flutter test --tags golden
```

**Update baselines** after intentional UI changes:

```bash
flutter test --tags golden --update-goldens
```

**CI** (`.github/workflows/flutter.yml`): runs `flutter test` with **`--exclude-tags golden`** so goldens stay optional on every push; run goldens locally when you change layout.
