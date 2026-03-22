/// Demo/prod toggles via `--dart-define` (no secrets in repo).
class AppConfig {
  AppConfig._();

  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );
}
