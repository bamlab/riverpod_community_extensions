import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityStreamProvider tests', () {
    test('connectivityStreamProvider provides an AsyncValue', () {
      final container = ProviderContainer();
      final providerState = container.read(connectivityStreamProvider);

      // Check that the initial state is AsyncLoading.
      expect(providerState, isA<AsyncLoading<List<ConnectivityResult>>>());
    });
  });
}
