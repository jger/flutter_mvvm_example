// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel manages state and business logic
/// Extends Notifier following MVVM pattern (Riverpod 3.x)

@ProviderFor(TodosViewModel)
const todosViewModelProvider = TodosViewModelProvider._();

/// ViewModel manages state and business logic
/// Extends Notifier following MVVM pattern (Riverpod 3.x)
final class TodosViewModelProvider
    extends $NotifierProvider<TodosViewModel, TodosState> {
  /// ViewModel manages state and business logic
  /// Extends Notifier following MVVM pattern (Riverpod 3.x)
  const TodosViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosViewModelHash();

  @$internal
  @override
  TodosViewModel create() => TodosViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodosState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodosState>(value),
    );
  }
}

String _$todosViewModelHash() => r'2abbb28d6c32a3b9dbd8caf565f201321e4050af';

/// ViewModel manages state and business logic
/// Extends Notifier following MVVM pattern (Riverpod 3.x)

abstract class _$TodosViewModel extends $Notifier<TodosState> {
  TodosState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TodosState, TodosState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodosState, TodosState>,
              TodosState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
