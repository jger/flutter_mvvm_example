/// Domain-level failures from the todo data layer (mapping, network, etc.).
sealed class TodoFailure implements Exception {
  const TodoFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class TodoFailureUnknown extends TodoFailure {
  const TodoFailureUnknown(super.message);
}

final class TodoFailureNotFound extends TodoFailure {
  const TodoFailureNotFound(super.message);
}
