import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Adds caching functionality to AutoDisposeFutureProviderRef<T> objects.
///
/// Keeps auto dispose future providers alive
/// for a specified duration, preventing them from being disposed immediately
/// after they're no longer listened to.
///
/// See [cacheDataFor]
extension CacheDataForExtension<T> on AutoDisposeFutureProviderRef<T> {
  /// When invoked, keeps the data state of your provider alive for [duration].
  /// Doesn't impact the error and loading states of the provider.
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
    var link = keepAlive();
    var timer = Timer(duration, link.close);

    onDispose(() {
      timer.cancel();
    });

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
