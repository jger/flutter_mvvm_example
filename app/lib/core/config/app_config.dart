/// Demo/prod toggles via `--dart-define` (no secrets in repo).
class AppConfig {
  AppConfig._();

  /// Whether demo mode is enabled (`DEMO_MODE` dart-define, default true).
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );
}
