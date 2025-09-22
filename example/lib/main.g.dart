// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CacheDataFor)
const cacheDataForProvider = CacheDataForProvider._();

final class CacheDataForProvider
    extends $AsyncNotifierProvider<CacheDataFor, int> {
  const CacheDataForProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cacheDataForProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cacheDataForHash();

  @$internal
  @override
  CacheDataFor create() => CacheDataFor();
}

String _$cacheDataForHash() => r'0cdaf6d64d8cb173d00601f0a58b4bcb454c0c2c';

abstract class _$CacheDataFor extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<int>, int>, AsyncValue<int>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
