import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';
import 'package:riverpod_community_extensions/src/refresh_when_network_available_extension.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RefreshWhenNetworkAvailableExtension Tests', () {
    late StreamController<List<ConnectivityResult>> connectivityController;
    late ProviderContainer container;
    late AutoDisposeFutureProvider<int> myProvider;
    late Stream<List<ConnectivityResult>> connectivityStream;

    var numberOfFetchDataCalls = 0;

    Future<int> fetchData() {
      numberOfFetchDataCalls++;

      return Future.value(42);
    }

    setUp(() {
      numberOfFetchDataCalls = 0;
      connectivityController = StreamController<List<ConnectivityResult>>();
      connectivityStream = connectivityController.stream;
    });

    tearDown(() {
      connectivityController.close();
      container.dispose();
    });

    test(
        'Should not refresh when connectivity does not change to available '
        'and provider has data', () async {
      myProvider = FutureProvider.autoDispose<int>((ref) async {
        ref.refreshWhenNetworkAvailable();

        return fetchData();
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(myProvider, (_, __) {});
      expect(numberOfFetchDataCalls, equals(1));

      // Simulate network being offline
      connectivityController.add([ConnectivityResult.none]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should not refresh when connectivity changes to available '
        'and provider has data', () async {
      myProvider = FutureProvider.autoDispose<int>((ref) async {
        ref.refreshWhenNetworkAvailable();

        return fetchData();
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(myProvider, (_, __) {});
      expect(numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should not refresh when connectivity does not change to available '
        'and provider has error', () async {
      myProvider = FutureProvider.autoDispose<int>((ref) async {
        ref.refreshWhenNetworkAvailable();
        await fetchData();
        throw const FormatException('No network mock exception');
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(myProvider, (_, __) {});
      expect(numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.none]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should refresh when connectivity changes to available '
        'and provider has error', () async {
      myProvider = FutureProvider.autoDispose<int>((ref) async {
        ref.refreshWhenNetworkAvailable();
        await fetchData();
        throw const FormatException('No network mock exception');
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(myProvider, (_, __) {});
      expect(numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(2));
    });

    test(
        'Should refresh only once when connectivity changes '
        'if provider is in error and is then updated to data', () async {
      var shouldThrow = true;

      myProvider = FutureProvider.autoDispose<int>((ref) async {
        ref.refreshWhenNetworkAvailable();
        final data = await fetchData();

        if (shouldThrow) {
          throw const FormatException('No network mock exception');
        }

        return data;
      });

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(myProvider, (_, __) {
          shouldThrow = false;
        });
      expect(numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(2));

      connectivityController.add([ConnectivityResult.none]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      connectivityController.add([ConnectivityResult.wifi]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(numberOfFetchDataCalls, equals(2));
    });
  });
}
