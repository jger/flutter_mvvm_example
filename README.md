# Flutter MVVM example

Sample app that demonstrates **MVVM with Riverpod**, a **fake backend** (Firebase-shaped API), and a clear split between **data**, **domain**, and **features**. Use it as a reference for layering, typed errors, and testable view models—not as production infrastructure.

## What you get

| Area | Details |
|------|---------|
| **State & UI** | `hooks_riverpod` + `flutter_hooks` (`HookConsumerWidget`, `useScrollController`, …), `@riverpod` view models, Material 3, light/dark (system) |
| **Data** | `FakeFirebaseService` (delays, `getTodosPage` with filter/sort simulated in-memory for the fake only, `watchTodos`) + `TodoRepository` — a real backend would apply filter/sort in queries, not duplicate domain logic client-side for paging |
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

Flutter version is pinned with **[FVM](https://fvm.app/)** (`app/.fvm/fvm_config.json`, **3.41.5**). Install FVM, then:

```bash
cd app
fvm install
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run -d chrome
```

Without FVM, install Flutter **3.41.5** (stable) and use `flutter` / `dart` instead of `fvm flutter` / `fvm dart`.

After changing `@riverpod` providers, regenerate code (same `build_runner` command).

## Tests & quality

```bash
fvm flutter test --coverage
fvm flutter analyze
```

**API docs (HTML):** In the repo **Settings → Pages**, set **Source** to **GitHub Actions**. On each push to `main` that touches `app/lib/` (or manually via **Actions → API documentation → Run workflow**), **`.github/workflows/docs.yml`** runs `dart doc` in `app/` and deploys the site (package API under `package:flutter_mvvm_example/…`). The public URL is **`https://jger.github.io/flutter_mvvm_example/`**.

- **Unit / VM tests**: view models with `ProviderScope` overrides (e.g. fake service with zero delay).
- **Widget tests**: `MaterialApp(home: TodosPage)` and interaction tests.
- **Golden tests** (opt-in tag `golden`): baseline PNGs under `test/goldens/`. Fonts load via `test/flutter_test_config.dart` and `golden_toolkit` so text does not render as tofu.

**Run goldens locally** (compare to committed images):

```bash
cd app && fvm flutter test --tags golden
```

**Update baselines on Linux (matches CI)** — golden PNGs are platform-sensitive (macOS ≠ Ubuntu). Use Docker to generate them on the same OS as CI:

```bash
# Regenerate PNGs on Linux → writes into app/test/goldens/
# (builds docker image locally on first run if missing)
make goldens-update

# Commit the updated baselines
git add app/test/goldens/ && git commit -m "chore: update goldens for Linux CI [skip ci]"
```

`make goldens-test` runs the comparison inside the container without updating files (mirrors the CI check). After changing `docker/goldens/Dockerfile` or the FVM Flutter version, run `make goldens-build` to rebuild the image.

**CI**: **`.github/workflows/docs.yml`** publishes dartdoc to GitHub Pages (same FVM Flutter as the app). **`.github/workflows/flutter.yml`** reads Flutter **3.41.5** from FVM (`jq` on `app/.fvm/fvm_config.json` → `subosito/flutter-action`), runs `flutter test` with **`--exclude-tags golden`** (coverage + analyze + translation check). **`.github/workflows/golden.yml`** + **`.github/actions/flutter-golden-tests`**: `flutter test --tags golden` on `ubuntu-latest`. Translation keys: `fvm dart run tool/check_translation_keys.dart` (de/el must match `en.json`). **`FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`** for JS-based actions (see GitHub changelog on Node 20 deprecation).

## Accessibility

The todo list uses a **`Semantics`** region with a localized label for the scrollable list. Individual todo rows expose title and completion to assistive tech. Prefer testing with TalkBack / VoiceOver when changing list or dialog behavior.

## Configuration / secrets (demo)

- **`AppConfig`** (`app/lib/core/config/app_config.dart`): `DEMO_MODE` via `--dart-define` (default `true`). No API keys are stored in the repo; production apps should load secrets from CI or a vault, not from Dart source.

## Releases (semantic-release)

Versions and GitHub Releases are driven by **[semantic-release](https://github.com/semantic-release/semantic-release)** at the repo root (`package.json`, `release.config.cjs`). **Use [Conventional Commits](https://www.conventionalcommits.org/)** (`feat:`, `fix:`, `chore:`, …) on `main`/`master` so releases and changelog entries are generated correctly. The release workflow bumps **`app/pubspec.yaml`** and commits `CHANGELOG.md` with **`[skip ci]`** on the release commit.
