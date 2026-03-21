import 'dart:developer' as developer;

/// Structured logging; replace with Crashlytics/analytics wiring in production.
class AppLogger {
  void log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, error: error, stackTrace: stackTrace);
  }
}
