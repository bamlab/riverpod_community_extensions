import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Adds caching functionality to AsyncNotifier providers.
///
/// This extension provides a [cacheDataFor] method that keeps auto-dispose
/// async notifiers alive for a specified duration, preventing them from being
/// disposed immediately after they're no longer listened to.
///
/// The caching only affects the data state of the provider and doesn't impact
/// error or loading states.
///
/// See [cacheDataFor] for usage details.
extension CacheDataForExtension<T> on AnyNotifier<AsyncValue<T>, T> {
  /// Keeps the data state of this AsyncNotifier alive for the specified
  /// [duration].
  ///
  ///
  /// This is particularly useful for expensive operations that you want to
  /// cache temporarily, such as network requests or heavy computations.
  ///
  /// Example usage:
  ///
  /// Without code-gen
  ///
  /// ```dart
  /// final userProvider = AsyncNotifierProvider<UserNotifier, User>(
  ///   UserNotifier.new,
  ///   isAutoDispose: true,
  /// );
  ///
  /// class UserNotifier extends AutoDisposeAsyncNotifier<User> {
  ///   @override
  ///   Future<User> build() async {
  ///     ref.cacheDataFor(const Duration(minutes: 5));
  ///
  ///     return await fetchUserFromApi();
  ///   }
  /// }
  /// ```
  ///
  /// With code-gen
  ///
  /// ```dart
  /// @riverpod
  /// class UserNotifier extends _$UserNotifier {
  ///   @override
  ///   Future<User> build() async {
  ///     ref.cacheDataFor(const Duration(minutes: 5));
  ///
  ///     return await fetchUserFromApi();
  ///   }
  /// }
  /// ```
  void cacheDataFor(Duration duration) {
    var link = ref.keepAlive();
    var timer = Timer(duration, link.close);

    ref.onDispose(() {
      timer.cancel();
    });

    // ignore: deprecated_member_use, ok for riverpod v2
    listenSelf((_, newAsyncValue) {
      // Use Riverpod 3.0's sealed AsyncValue for exhaustive pattern matching
      switch (newAsyncValue) {
        case AsyncLoading():
          // Do nothing during loading - keep existing cache
          break;
        case AsyncData():
          // Reset cache timer when new data arrives
          timer.cancel();
          link.close();

          link = ref.keepAlive();
          timer = Timer(duration, link.close);
        case AsyncError():
          // Clear cache immediately on error
          timer.cancel();
          link.close();
      }
    });
  }
}
