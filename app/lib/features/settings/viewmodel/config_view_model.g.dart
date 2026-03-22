// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for app configuration (theme; locale is applied in the view via EasyLocalization).

@ProviderFor(ConfigViewModel)
const configViewModelProvider = ConfigViewModelProvider._();

/// ViewModel for app configuration (theme; locale is applied in the view via EasyLocalization).
final class ConfigViewModelProvider
    extends $NotifierProvider<ConfigViewModel, ConfigState> {
  /// ViewModel for app configuration (theme; locale is applied in the view via EasyLocalization).
  const ConfigViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configViewModelHash();

  @$internal
  @override
  ConfigViewModel create() => ConfigViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigState>(value),
    );
  }
}

String _$configViewModelHash() => r'1c7887ecfee49e07924a1d32eefb460db8be5df0';

/// ViewModel for app configuration (theme; locale is applied in the view via EasyLocalization).

abstract class _$ConfigViewModel extends $Notifier<ConfigState> {
  ConfigState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConfigState, ConfigState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConfigState, ConfigState>,
              ConfigState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
