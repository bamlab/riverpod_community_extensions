import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';

part 'providers.g.dart';

@riverpod
Future<int> cacheDataFor(CacheDataForRef ref) async {
  ref.cacheDataFor(const Duration(seconds: 4));
  await Future.delayed(const Duration(seconds: 3));
  return 42;
}
