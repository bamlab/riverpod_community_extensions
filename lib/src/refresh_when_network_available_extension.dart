import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';

/// Adds network-aware refresh functionality to
/// `Ref<T>` objects.
/// This extension uses the connectivity_plus package to listen for network
/// status changes and refreshes the provider when the network becomes
/// available if it's in error state.
///
/// See [refreshWhenNetworkAvailable]
extension RefreshWhenNetworkAvailableExtension<T> on Ref<T> {
  /// Refreshes the provider when the network becomes available after being
  /// unavailable, if the provider is in error state.
  ///
  /// This extension can only be used inside FutureProvider. Otherwise, it will
  /// have no effect.
  ///
  /// Example usages:
  ///
  /// without codegen:
  /// ```dart
  /// final myProvider = FutureProvider.autoDispose<int>((ref) async {
  ///   ref.refreshWhenNetworkAvailable();
  ///   final result = await fetchData(); // Assume fetchData is a function that fetches data over the network.
  ///   return result;
  /// });
  /// ```
  ///
  /// with codegen:
  /// ```dart
  /// @riverpod
  /// Future<int> myProvider(MyProviderRef ref) async {
  ///   ref.refreshWhenNetworkAvailable();
  ///   final result = await fetchData();
  ///   return result;
  /// }
  /// ```
  void refreshWhenNetworkAvailable() {
    assert(
      // ignore: deprecated_member_use, ok for riverpod v2
      this is FutureProviderRef,
      'refreshWhenNetworkAvailable can only be used on '
      'FutureProviderRef',
    );
    // ignore: deprecated_member_use, ok for riverpod v2
    if (this is! FutureProviderRef) return;
    // ignore: deprecated_member_use, ok for riverpod v2
    final ref = this as FutureProviderRef;

    var isNetworkAvailable = false;
    const validResults = [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn,
      ConnectivityResult.other,
    ];

    listen(connectivityStreamProvider, (_, connectivityResults) {
      connectivityResults.whenData((data) {
        final currentlyAvailable =
            data.any((result) => validResults.contains(result));
        if (currentlyAvailable && !isNetworkAvailable) {
          isNetworkAvailable = true;
          if (ref.state.hasError) {
            invalidateSelf();
          }
        } else {
          isNetworkAvailable = false;
        }
      });
    });
  }
}
