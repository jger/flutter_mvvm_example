/// Domain-level failures from the todo data layer (mapping, network, etc.).
sealed class TodoFailure implements Exception {
  /// Creates a failure with a user- or log-facing [message].
  const TodoFailure(this.message);

  /// Human-readable explanation.
  final String message;

  @override
  String toString() => message;
}

/// Unclassified error (wrapped underlying message).
final class TodoFailureUnknown extends TodoFailure {
  /// Creates an unknown failure with [message].
  const TodoFailureUnknown(super.message);
}

/// Requested entity was not found.
final class TodoFailureNotFound extends TodoFailure {
  /// Creates a not-found failure with [message].
  const TodoFailureNotFound(super.message);
}
