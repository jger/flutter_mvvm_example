import 'package:app/core/logging/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_logger_provider.g.dart';

/// Provides a shared [AppLogger] instance.
@riverpod
AppLogger appLogger(Ref ref) {
  return AppLogger();
}
