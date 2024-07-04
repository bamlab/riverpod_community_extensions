import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';

/// Adds network-aware refresh functionality to AutoDisposeRef<T> objects.
/// This extension uses the connectivity_plus package to listen for network
/// status changes and refreshes the provider when the network becomes
/// available.
///
/// See [refreshWhenNetworkAvailable]
extension RefreshWhenNetworkAvailableExtension<T> on AutoDisposeRef<T> {
  /// Refreshes the provider when the network becomes available after being
  /// unavailable.
  ///
  /// This can be useful for scenarios where data needs to be fetched or
  /// operations need to be performed only when network connectivity is
  /// restored, such as synchronizing local data with a server.
  ///
  /// Example usages:
  ///
  /// without codegen:
  /// ```dart
  /// final myProvider = Provider.autoDispose<int>((ref) {
  ///   ref.refreshWhenNetworkAvailable();
  ///   return fetchData(); // Assume fetchData is a function that fetches data over the network.
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// int myProvider(AutoDisposeRef ref) {
  ///   ref.refreshWhenNetworkAvailable();
  ///   return fetchData();
  /// }
  /// ```
  void refreshWhenNetworkAvailable() {
    final connectivityStream = Connectivity().onConnectivityChanged;

    var isNetworkAvailable = false;
    const validResults = [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn,
      ConnectivityResult.other,
    ];

    final connectivitySubscription =
        connectivityStream.listen((connectivityResults) {
      final currentlyAvailable =
          connectivityResults.any((result) => validResults.contains(result));
      if (currentlyAvailable && !isNetworkAvailable) {
        isNetworkAvailable = true;
        invalidateSelf();
      } else {
        isNetworkAvailable = false;
      }
    });

    onDispose(connectivitySubscription.cancel);
  }
}
