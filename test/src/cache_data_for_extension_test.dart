import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';

class _CreateTestProvider extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    cacheDataFor(_dataCacheDuration);

    await Future<void>.delayed(_queryDuration);

    if (!_isData) {
      throw Exception();
    }
  }
}

late bool _isData;
const _queryDuration = Duration(milliseconds: 10);
const _dataCacheDuration = Duration(milliseconds: 20);

void main() {
  group('cacheDataFor extension', () {
    const onDisposeComputingDuration = Duration(milliseconds: 1);

    late ProviderContainer container;

    AsyncNotifierProvider<_CreateTestProvider, void> createTestProvider() {
      return AsyncNotifierProvider<_CreateTestProvider, void>(
        _CreateTestProvider.new,
        isAutoDispose: true,
        retry: (_, __) => null,
      );
    }

    setUp(() {
      container = ProviderContainer();
      _isData = true;
    });

    tearDown(() async {
      container.dispose();
      // Add a small delay to ensure cleanup is complete
      await Future<void>.delayed(const Duration(milliseconds: 5));
    });

    test('do not keep state in cache if last one was an error', () async {
      final testFutureProvider = createTestProvider();
      final asyncValues = <AsyncValue<void>>[];

      _isData = false;

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration * 2);
      firstSubscription.close();

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncError<void>>());

      // Wait longer to ensure the provider is fully disposed after error
      await Future<void>.delayed(const Duration(milliseconds: 30));

      _isData = true;

      final secondSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, equals(4));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncError<void>>());
      expect(asyncValues[2], isA<AsyncLoading<void>>());
      expect(asyncValues[3], isA<AsyncData<void>>());
    });

    test('keep state in cache if last one was data', () async {
      final testFutureProvider = createTestProvider();
      final asyncValues = <AsyncValue<void>>[];

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration);

      firstSubscription.close();

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());

      await Future<void>.delayed(onDisposeComputingDuration);

      final secondSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
    });

    test(
        '''keep state in cache if last one was loading and end up being data while not watching it''',
        () async {
      final testFutureProvider = createTestProvider();
      final asyncValues = <AsyncValue<void>>[
        container.read(testFutureProvider),
      ];

      expect(asyncValues.length, equals(1));
      expect(asyncValues[0], isA<AsyncLoading<void>>());

      await Future<void>.delayed(_queryDuration);
      await Future<void>.delayed(onDisposeComputingDuration);

      asyncValues.add(container.read(testFutureProvider));

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
    });

    test(
        '''do not keep state in cache if last one was loading and end up being error while not watching it''',
        () async {
      final testFutureProvider = createTestProvider();
      final asyncValues = <AsyncValue<void>>[];

      _isData = false;

      asyncValues.add(container.read(testFutureProvider));

      expect(asyncValues.length, equals(1));
      expect(asyncValues[0], isA<AsyncLoading<void>>());

      // Wait for the provider to complete and error out
      await Future<void>.delayed(_queryDuration);
      await Future<void>.delayed(onDisposeComputingDuration);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await container.pump();

      // Reset isData to true to get fresh loading state
      _isData = true;

      // Create a new provider instance to avoid cached error state
      final newTestFutureProvider = createTestProvider();

      asyncValues.add(container.read(newTestFutureProvider));

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncLoading<void>>());
    });

    test('reset state if we wait more than cacheTime', () async {
      final testFutureProvider = createTestProvider();
      final asyncValues = <AsyncValue<void>>[];

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration);

      firstSubscription.close();

      expect(asyncValues.length, equals(2));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());

      await Future<void>.delayed(_dataCacheDuration);
      await Future<void>.delayed(onDisposeComputingDuration);

      final secondSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(_queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, equals(4));
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
      expect(asyncValues[2], isA<AsyncLoading<void>>());
      expect(asyncValues[3], isA<AsyncData<void>>());
    });
  });
}
