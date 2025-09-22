import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';

part 'providers.g.dart';

@riverpod
class CacheDataFor extends _$CacheDataFor {
  @override
  FutureOr<int> build() {
    cacheDataFor(const Duration(seconds: 4));

    return 42;
  }
}
