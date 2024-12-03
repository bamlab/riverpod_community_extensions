import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

/// Adds auto-refresh functionalities to AutoDisposeRef<T> objects.
///
/// See [autoRefresh] and [refreshWhenReturningToForeground] for more details.
extension RefreshExtension<T> on AutoDisposeRef<T> {
  /// Refreshes the value at the specified interval.
  ///
  /// Example usages:
  ///
  /// without codegen:
  /// ```dart
  /// final dataProvider = Provider<int>((ref) {
  ///   ref.autoRefresh(const Duration(seconds: 1));
  ///   return fetchData();
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// int data(DataRef ref) {
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
  /// Example usages:
  /// without codegen:
  /// ```dart
  /// final dataProvider = Provider<int>((ref) {
  ///   ref.refreshWhenReturningToForeground();
  ///   return fetchData();
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// int data(DataRef ref) {
  ///   ref.refreshWhenReturningToForeground();
  ///   return fetchData();
  /// }
  /// ```
  ///
  void refreshWhenReturningToForeground() {
    final listener = AppLifecycleListener(onResume: invalidateSelf);
    onDispose(listener.dispose);
  }
}
