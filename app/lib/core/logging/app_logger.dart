import 'dart:developer' as developer;

/// Structured logging; replace with Crashlytics/analytics wiring in production.
class AppLogger {
  /// Writes [message] to the developer log; optional [error] and [stackTrace].
  void log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, error: error, stackTrace: stackTrace);
  }
}
