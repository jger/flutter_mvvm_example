# Configuration / secrets (demo)

- **`AppConfig`** (`app/lib/core/config/app_config.dart`): `DEMO_MODE` via `--dart-define` (default `true`). No API keys are stored in the repo; production apps should load secrets from CI or a vault, not from Dart source.

- **Coverage badge** (CI), first time:
  1. [gist.github.com](https://gist.github.com/) → **Create** a gist (any filename, e.g. `placeholder.txt`, content can be empty) → **Create public gist**.
  2. From the URL `https://gist.github.com/<user>/<GIST_ID>` copy **`<GIST_ID>`** (long hex string).
  3. Repo **Settings → Secrets and variables → Actions → Variables → New**: **`COVERAGE_GIST_ID`** = that ID.
  4. **Settings → Developer settings → Personal access tokens** → token with scope **`gist`** (classic) or fine-grained with gist access → copy once.
  5. Repo **Settings → Secrets → Actions → New**: **`GIST_SECRET`** = that token.
  6. Push to **main**/**master** (or open an internal PR) so **Flutter CI** runs; then **Actions → Flutter CI → latest run → Summary**: copy the badge line for the README, or replace **`GIST_ID_PLACEHOLDER`** in `README.md` with your gist ID.

  If Shields shows **resource not found**, the placeholder is still in `README.md` or CI hasn’t written **`coverage.json`** to the gist yet. Fork PRs: no secrets → badge step skipped.
