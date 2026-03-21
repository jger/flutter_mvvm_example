// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoInitialUi)
const todoInitialUiProvider = TodoInitialUiProvider._();

final class TodoInitialUiProvider
    extends $FunctionalProvider<TodoInitialUi, TodoInitialUi, TodoInitialUi>
    with $Provider<TodoInitialUi> {
  const TodoInitialUiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoInitialUiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoInitialUiHash();

  @$internal
  @override
  $ProviderElement<TodoInitialUi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodoInitialUi create(Ref ref) {
    return todoInitialUi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoInitialUi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoInitialUi>(value),
    );
  }
}

String _$todoInitialUiHash() => r'a9c33091d118a122fac64acc45374dd7df797bc9';

@ProviderFor(firebaseService)
const firebaseServiceProvider = FirebaseServiceProvider._();

final class FirebaseServiceProvider
    extends
        $FunctionalProvider<
          FakeFirebaseService,
          FakeFirebaseService,
          FakeFirebaseService
        >
    with $Provider<FakeFirebaseService> {
  const FirebaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseServiceHash();

  @$internal
  @override
  $ProviderElement<FakeFirebaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FakeFirebaseService create(Ref ref) {
    return firebaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeFirebaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeFirebaseService>(value),
    );
  }
}

String _$firebaseServiceHash() => r'8c464474b6d0bab1c69d4630c756a235d4a54a3d';

@ProviderFor(todoRepository)
const todoRepositoryProvider = TodoRepositoryProvider._();

final class TodoRepositoryProvider
    extends $FunctionalProvider<TodoRepository, TodoRepository, TodoRepository>
    with $Provider<TodoRepository> {
  const TodoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodoRepository create(Ref ref) {
    return todoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoRepository>(value),
    );
  }
}

String _$todoRepositoryHash() => r'2930e7fdc7220c71e992741bb2d3b10f0dcc1c8a';
