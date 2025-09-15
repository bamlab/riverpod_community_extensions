import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Adds debounce functionality to AutoDisposeFutureProviderRef<T> objects.
/// allows you to delay an operation to reduce redundant calls.
///
/// See [debounce]
extension DebounceExtension on Ref {
  /// Debounces an operation until the specified [Duration] has passed without
  /// any further invocations.
  ///
  /// This can be useful for scenarios where you want to delay an operation
  /// until a user has stopped interacting with a UI element to reduce redundant
  /// calls.
  ///
  /// Example usages:
  ///
  /// without codegen:
  /// ```dart
  /// final myFutureProvider = FutureProvider<int>((ref) async {
  ///   await ref.debounce(const Duration(milliseconds: 300));
  ///   // Perform expensive operation after a debounce of 300 milliseconds.
  ///   return fetchData();
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// Future<int> myFuture(MyFutureRef ref) async {
  ///   await ref.debounce(const Duration(milliseconds: 300));
  ///   // Perform expensive operation after a debounce of 300 milliseconds.
  ///   return fetchData();
  /// }
  /// ```
  Future<void> debounce(Duration duration) {
    final completer = Completer<void>();
    final timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    onDispose(() {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(StateError('Cancelled'));
      }
    });

    return completer.future;
  }
}
