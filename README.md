# Flutter MVVM example

<!-- Replace GIST_ID_PLACEHOLDER with your gist ID (same as COVERAGE_GIST_ID), or copy the line from Actions → Flutter CI → Summary. -->
[![coverage](https://img.shields.io/endpoint?url=https%3A%2F%2Fgist.githubusercontent.com%2Fjger%2F04ccfed88313b3d6dabd423fe99f026a%2Fraw%2Fcoverage.json)](https://github.com/jger/flutter_mvvm_example/actions)

Sample app that demonstrates **MVVM with Riverpod**, a **fake backend** (Firebase-shaped API), and **feature-first** modules (`models`, `data`, `repositories`, `view` / `viewmodel`) plus **core** shared code. Use it as a reference for layering, typed errors, and testable view models—not as production infrastructure.

## What you get

| Area | Details |
|------|---------|
| **State & UI** | `hooks_riverpod` + `flutter_hooks` (`HookConsumerWidget`, `useScrollController`, …), `@riverpod` view models, Material 3, light/dark (system) |
| **Data** | [`features/todos/data/services/fake_firebase_service.dart`](app/lib/features/todos/data/services/fake_firebase_service.dart) — delays, `getTodosPage` (filter/sort in-memory for the fake only), `watchTodos`; [`todo_repository.dart`](app/lib/features/todos/repositories/todo_repository.dart) — a real backend would apply filter/sort in queries, not duplicate domain logic client-side for paging |
| **Persistence** | [`features/todos/data/local/todo_persistence.dart`](app/lib/features/todos/data/local/todo_persistence.dart) + `SharedPreferences`, wired in `main()` with provider overrides |
| **Navigation** | `go_router`: `/` (todos), `/config` (settings) |
| **i18n** | easy_localization — EN / DE / EL |
| **Logging** | `AppLogger` in `core/logging` |
| **Models (todos)** | [`features/todos/models/`](app/lib/features/todos/models/) — `Todo`, `TodoFilter` / `TodoSort`, sealed **`TodoFailure`**; repository maps services to `TodoFailure` for callers |
| **Errors & recovery** | User-visible messages from failures; snackbar + **retry** for failed mutations (`pendingRetry` on `TodosViewModel`) |
| **a11y** | **`Accessibility Semantics`** region for the scrollable list (localized label); rows expose title and completion; validate with TalkBack / VoiceOver |
| **Demo config** | **`AppConfig`**: `DEMO_MODE` via `--dart-define` (default `true`); no API keys in source |
| **Tests** | Unit/widget (`test/`, incl. **ViewModel error paths** in `todo_view_model_error_test.dart`), **integration** (`integration_test/` — separate from `test/` + coverage), **golden** (`golden_toolkit`, tag `golden`); CI **≥75%** line coverage on `test/`; Linux in Docker: `make goldens-*`, **`make integration-tests`** (`docker/integration-tests/`) |

Todos: filter, sort, edit title (dialog), pull-to-refresh, max content width on web.

## Documentation

**Dart API reference (dartdoc)** for `package:flutter_mvvm_example` — libraries, classes, and public members generated from `app/lib/`:

**[flutter_mvvm_example — browse API docs](https://jger.github.io/flutter_mvvm_example/index.html)**

Deployment is handled by GitHub Actions; see **GitHub Actions** and **Makefile** at the end of this README.

## Architecture

- **`features/todos/`** — [`models/`](app/lib/features/todos/models/) (`Todo`, filters, **`TodoFailure`**), [`data/local`](app/lib/features/todos/data/local/) + [`data/services`](app/lib/features/todos/data/services/), [`repositories/`](app/lib/features/todos/repositories/), [`view/`](app/lib/features/todos/view/) (`TodosPage`, `FloatingTodoComposer`, …; shared pieces under [`view/widgets/`](app/lib/features/todos/view/widgets/)), [`viewmodel/`](app/lib/features/todos/viewmodel/) (`TodosViewModel`, `TodosState`, providers).
- **`features/settings/`** — [`models/`](app/lib/features/settings/models/), [`view/`](app/lib/features/settings/view/), [`viewmodel/`](app/lib/features/settings/viewmodel/) (theme via `core/theme`; locale via `easy_localization` — no feature-local repository).
- **`core/`**: `AppLogger`, router, theme, config, …

Flow: **View → ViewModel → Repository → Service**. The UI does not talk to the fake Firebase directly.

## Error handling

Failures are modeled in the domain and handled in one place per operation:

1. **`TodoFailure`** ([`features/todos/models/todo_failure.dart`](app/lib/features/todos/models/todo_failure.dart)) — sealed class with variants such as `TodoFailureUnknown` and `TodoFailureNotFound`, each carrying a **`message`** for the UI.
2. **`TodoRepository`** ([`features/todos/repositories/todo_repository.dart`](app/lib/features/todos/repositories/todo_repository.dart)) wraps service calls: unexpected exceptions are converted to **`TodoFailureUnknown`** (or typed failures where the service throws them), so callers see a single error type from the data layer.
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
# Coverage + unit/widget tests only (path `test/` — used for the CI coverage gate)
fvm flutter test test --coverage --exclude-tags golden

# Integration tests — separate invocation (required); pick a desktop device, e.g.:
fvm flutter test integration_test -d macos   # local
# CI runs: `xvfb-run -a flutter test integration_test -d linux` (virtual display; plain `-d linux` on headless Ubuntu often fails to attach)

fvm flutter analyze
```

Flutter does **not** allow `flutter test test integration_test` in a single command with coverage; run the two commands above.

- **Unit / VM tests**: view models with `ProviderScope` overrides (e.g. fake service with zero delay), including error/retry paths in `test/todo_view_model_error_test.dart`.
- **Widget tests**: `MaterialApp(home: TodosPage)` and interaction tests.
- **Integration tests**: `integration_test/app_test.dart` — smoke + navigation (`MainApp` + router), same localization/provider wiring as production.
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

**Integration tests on Linux (matches CI)** — GitHub Actions and `docker/integration-tests` use the same **APT set** + **`flutter precache --linux`** + **`xvfb-run -a flutter test integration_test -d linux`**. Locally without a Linux desktop:

```bash
# First run builds image `flutter-integration-tests:<FVM version>` if missing
make integration-tests

# Rebuild image after Dockerfile or Flutter version change
make integration-tests-build
```

## Accessibility (a11y)

The todo list uses a **`Semantics`** region with a localized label for the scrollable list. Individual todo rows expose title and completion to assistive tech. Prefer testing with TalkBack / VoiceOver when changing list or dialog behavior.

## Releases (semantic-release)

Versions and GitHub Releases are driven by **[semantic-release](https://github.com/semantic-release/semantic-release)** at the repo root (`package.json`, `release.config.cjs`). **Use [Conventional Commits](https://www.conventionalcommits.org/)** (`feat:`, `fix:`, `chore:`, …) on `main`/`master` so releases and changelog entries are generated correctly. The release workflow bumps **`app/pubspec.yaml`** and commits `CHANGELOG.md` with **`[skip ci]`** on the release commit.

## GitHub Actions

| Workflow | Role |
|----------|------|
| **`.github/workflows/docs.yml`** | Runs `dart doc` in `app/` when pushes to `main` touch `app/lib/`, or manually via **Actions → API documentation → Run workflow**. Publishes HTML API docs to GitHub Pages (same FVM Flutter as the app). Set **Settings → Pages → Build and deployment → Source** to **GitHub Actions** so deploy works. Live docs: [flutter_mvvm_example API](https://jger.github.io/flutter_mvvm_example/index.html). |
| **`.github/workflows/flutter.yml`** | FVM Flutter (`subosito/flutter-action`). **APT:** build-essential, clang, cmake, ninja, pkg-config, GTK, **libblkid**, liblzma, **libglu1-mesa**, **xvfb** (aligned with `docker/integration-tests/Dockerfile`). **`flutter precache --linux`** then `flutter test test --coverage --exclude-tags golden`, **`very_good_coverage` ≥75%**, **`Schneegans/dynamic-badges-action`** (optional: **`GIST_SECRET`**, **`COVERAGE_GIST_ID`**), **`xvfb-run -a flutter test integration_test -d linux`**. Also `flutter analyze`, `dart format`, `build_runner`, `tool/check_translation_keys.dart`. |
| **`.github/workflows/golden.yml`** + **`.github/actions/flutter-golden-tests`** | `flutter test --tags golden` on `ubuntu-latest`. |

**`FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`** is set for JS-based actions (see GitHub’s Node 20 deprecation notes).

## Makefile (`make` at repo root)

Requires **Docker**. Flutter version comes from **`app/.fvm/fvm_config.json`**; images are tagged with that version (e.g. `flutter-goldens:3.41.5`).

| Target | Purpose |
|--------|---------|
| **`make goldens-build`** | Build `docker/goldens` image `flutter-goldens:<version>`. |
| **`make goldens-ensure-image`** | Build image only if missing. |
| **`make goldens-update`** | In container: `pub get`, `build_runner`, **`flutter test --update-goldens --tags golden`** → writes **`app/test/goldens/`**. |
| **`make goldens-test`** | In container: same prep, then **`flutter test --tags golden`** (compare only). |
| **`make integration-tests-build`** | Build `docker/integration-tests` image `flutter-integration-tests:<version>`. |
| **`make integration-tests-ensure-image`** | Build integration image only if missing. |
| **`make integration-tests`** | In container: `pub get`, `build_runner`, **`xvfb-run -a flutter test integration_test -d linux`**. |

After changing **`docker/goldens/Dockerfile`**, **`docker/integration-tests/Dockerfile`**, or the FVM Flutter version, run the corresponding **`*-build`** target so the image is rebuilt.
