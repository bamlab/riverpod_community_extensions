import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/connectivity_stream_provider.dart';
import 'package:riverpod_community_extensions/src/refresh_when_network_available_extension.dart';

class _MyProvider extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    refreshWhenNetworkAvailable();

    _numberOfFetchDataCalls++;

    if (_isError) {
      throw const FormatException('No network mock exception');
    }

    return 42;
  }
}

var _numberOfFetchDataCalls = 0;
var _isError = false;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RefreshWhenNetworkAvailableExtension Tests', () {
    late StreamController<List<ConnectivityResult>> connectivityController;
    late ProviderContainer container;
    late Stream<List<ConnectivityResult>> connectivityStream;

    AsyncNotifierProvider<_MyProvider, int> createMyProvider() {
      return AsyncNotifierProvider<_MyProvider, int>(
        _MyProvider.new,
        isAutoDispose: true,
        retry: (_, __) => null,
      );
    }

    setUp(() {
      _numberOfFetchDataCalls = 0;
      _isError = false;
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
      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(createMyProvider(), (_, __) {});
      expect(_numberOfFetchDataCalls, equals(1));

      // Simulate network being offline
      connectivityController.add([ConnectivityResult.none]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should not refresh when connectivity changes to available '
        'and provider has data', () async {
      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(createMyProvider(), (_, __) {});
      expect(_numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should not refresh when connectivity does not change to available '
        'and provider has error', () async {
      _isError = true;
      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(createMyProvider(), (_, __) {});
      expect(_numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.none]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(1));
    });

    test(
        'Should refresh when connectivity changes to available '
        'and provider has error', () async {
      _isError = true;
      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(createMyProvider(), (_, __) {});
      expect(_numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(2));
    });

    test(
        'Should refresh only once when connectivity changes '
        'if provider is in error and is then updated to data', () async {
      _isError = true;

      container = ProviderContainer(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => connectivityStream),
        ],
      )..listen(createMyProvider(), (_, __) {
          _isError = false;
        });
      expect(_numberOfFetchDataCalls, equals(1));

      // Simulate network being online
      connectivityController.add([ConnectivityResult.wifi]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(2));

      connectivityController.add([ConnectivityResult.none]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      connectivityController.add([ConnectivityResult.wifi]);
      // Wait for the potential refresh to happen
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(_numberOfFetchDataCalls, equals(2));
    });
  });
}
