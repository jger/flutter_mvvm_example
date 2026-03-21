// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$firebaseServiceHash() => r'2b85db4884ea166abf8351a23bbfe358ad43feb8';
