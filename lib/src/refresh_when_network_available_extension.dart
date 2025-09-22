import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';

/// Adds network-aware refresh functionality to AsyncNotifier providers.
///
/// This extension uses the connectivity_plus package to listen for network
/// status changes and refreshes the provider when the network becomes
/// available if it's in error state.
///
/// See [refreshWhenNetworkAvailable] for usage details.
extension RefreshWhenNetworkAvailableExtension<T>
    on AnyNotifier<AsyncValue<T>, T> {
  /// Refreshes the provider when the network becomes available after being
  /// unavailable, if the provider is in error state.
  ///
  /// This is particularly useful for network-dependent operations that should
  /// automatically retry when connectivity is restored.
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
  ///     ref.refreshWhenNetworkAvailable();
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
  ///     ref.refreshWhenNetworkAvailable();
  ///
  ///     return await fetchUserFromApi();
  ///   }
  /// }
  /// ```
  void refreshWhenNetworkAvailable() {
    var isNetworkAvailable = false;
    const validResults = [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn,
      ConnectivityResult.other,
    ];

    ref.listen(connectivityStreamProvider, (_, connectivityResults) {
      connectivityResults.whenData((data) {
        final currentlyAvailable =
            data.any((result) => validResults.contains(result));
        if (currentlyAvailable && !isNetworkAvailable) {
          isNetworkAvailable = true;
          // ignore: invalid_use_of_visible_for_testing_member, Safe because inside listenSelf
          if (state.hasError) {
            ref.invalidateSelf();
          }
        } else {
          isNetworkAvailable = false;
        }
      });
    });
  }
}
