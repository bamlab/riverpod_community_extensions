import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

/// Adds auto-refresh functionality to AutoDisposeRef<T> objects.
/// allows you to refresh a value at a specified interval.
///
/// See [autoRefresh]
extension AutoRefreshExtension<T> on AutoDisposeRef<T> {
  /// Refreshes the value at the specified interval.
  ///
  /// This can be useful for scenarios where you want to refresh a value at a
  /// specified interval.
  ///
  /// Example usages:
  ///
  /// without codegen:
  /// ```dart
  /// final myProvider = Provider<int>((ref) {
  ///   ref.autoRefresh(const Duration(seconds: 1));
  ///   return fetchData();
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// int myProvider(MyRef ref) {
  ///   ref.autoRefresh(const Duration(seconds: 1));
  ///   return fetchData();
  /// }
  /// ```
  void autoRefresh(Duration duration) {
    final timer = Timer(duration, invalidateSelf);
    onDispose(timer.cancel);
  }

  /// Refreshes the value each time the app returns to foreground.
  ///
  void refreshWhenReturningToForeground() {
    final listener = AppLifecycleListener(onResume: invalidateSelf);
    onDispose(listener.dispose);
  }
}
