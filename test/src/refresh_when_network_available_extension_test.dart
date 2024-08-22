import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';
import 'package:riverpod_community_extensions/src/refresh_when_network_available_extension.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RefreshWhenNetworkAvailableExtension Tests', () {
    late StreamController<List<ConnectivityResult>> connectivityController;
    late ProviderContainer container;
    late AutoDisposeProvider<int> myProvider;
    late Stream<List<ConnectivityResult>> connectivityStream;

    var numberOfFetchDataCalls = 0;

    int fetchData() {
      numberOfFetchDataCalls++;
      return 42;
    }

    setUp(() {
      numberOfFetchDataCalls = 0;
      connectivityController = StreamController<List<ConnectivityResult>>();
      connectivityStream = connectivityController.stream;

      myProvider = Provider.autoDispose<int>((ref) {
        ref.refreshWhenNetworkAvailable();
        return fetchData();
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith(
            (ref) => connectivityStream,
          ),
        ],
      )..listen(myProvider, (_, __) {});
    });

    tearDown(() {
      connectivityController.close();
      container.dispose();
    });

    test('Should not refresh when connectivity does not change to available',
        () async {
      expect(numberOfFetchDataCalls, 1);

      // Simulate network being offline
      connectivityController.add([ConnectivityResult.none]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, 1);
    });

    test('Should refresh when connectivity changes to available', () async {
      expect(numberOfFetchDataCalls, 1);

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, 2);
    });
  });
}
