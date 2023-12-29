// We need this extension to add cache to autoDispose providers
// This is from this issue https://github.com/rrousselGit/riverpod/issues/1664
import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Adds caching functionality to AutoDisposeRef<T> objects.
///
/// Keeps AutoDisposeRef<T> objects, typically Riverpod providers, alive
/// for a specified duration, preventing them from being disposed immediately
/// after they're no longer listened to.
///
/// See [cacheFor]
extension ProviderCache<T> on AutoDisposeRef<T> {
  /// Keeps the surrounding provider alive for [duration].
  ///
  /// Eg.
  /// ```dart
  /// final myProvider = Provider.autoDispose((ref) {
  ///   ref.cacheFor(const Duration(minutes: 5));
  ///
  ///   return 'myValue';
  /// });
  ///```
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}
