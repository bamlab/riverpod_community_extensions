import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Adds caching functionality to FutureProvider refs.
///
/// Keeps auto dispose future providers alive
/// for a specified duration, preventing them from being disposed immediately
/// after they're no longer listened to.
///
/// See [cacheDataFor]
extension CacheDataForExtension<T> on Ref<T> {
  /// When invoked, keeps the data state of your provider alive for [duration].
  /// Doesn't impact the error and loading states of the provider.
  ///
  /// This extension can only be used inside FutureProvider. Otherwise, it will
  /// have no effect.
  ///
  /// Example usages:
  /// without codegen:
  /// ```dart
  /// final myValueProvider = FutureProvider.autoDispose((ref) {
  ///   ref.cacheDataFor(const Duration(minutes: 5));
  ///
  ///   return Future.value('myValue');
  /// });
  ///```
  ///
  /// with codegen:
  ///```dart
  /// @riverpod
  /// Future<String> myValue (MyValueRef ref) async {
  ///   ref.cacheDataFor(const Duration(minutes: 5));
  ///
  ///   return Future.value('myValue');
  /// });
  ///```
  void cacheDataFor(Duration duration) {
    assert(
      // ignore: deprecated_member_use, ok for riverpod v2
      this is FutureProviderRef,
      'cacheDataFor can only be used on FutureProvider refs',
    );
    // ignore: deprecated_member_use, ok for riverpod v2
    if (this is! FutureProviderRef) return;

    var link = keepAlive();
    var timer = Timer(duration, link.close);

    onDispose(() {
      timer.cancel();
    });

    // ignore: deprecated_member_use, ok for riverpod v2
    listenSelf((_, newAsyncValue) {
      if (newAsyncValue is AsyncError<T>) {
        timer.cancel();
        link.close();
      } else if (newAsyncValue is AsyncData<T>) {
        timer.cancel();
        link.close();

        link = keepAlive();
        timer = Timer(duration, link.close);
      }
    });
  }
}
