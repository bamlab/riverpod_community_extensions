import 'package:riverpod/riverpod.dart';
import 'package:riverpods_community_extensions/riverpods_community_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('cacheDataFor extension', () {
    const queryDuration = Duration(milliseconds: 10);
    const dataCacheDuration = Duration(milliseconds: 20);
    const onDisposeComputingDuration = Duration(milliseconds: 1);

    var isData = true;
    var container = ProviderContainer();
    var testFutureProvider = FutureProvider.autoDispose((ref) async {});

    setUp(() {
      container = ProviderContainer();
      isData = true;
      testFutureProvider = FutureProvider.autoDispose((ref) async {
        ref.cacheDataFor(dataCacheDuration);

        await Future<void>.delayed(queryDuration);

        if (!isData) {
          throw Exception();
        }
      });
    });

    tearDown(() {
      container.dispose();
    });

    test('do not keep state in cache if last one was an error', () async {
      final asyncValues = <AsyncValue<void>>[];

      isData = false;

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(queryDuration);

      firstSubscription.close();

      expect(asyncValues.length, 2);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncError<void>>());

      await Future<void>.delayed(onDisposeComputingDuration);

      isData = true;

      final secondSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, 4);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncError<void>>());
      expect(asyncValues[2], isA<AsyncLoading<void>>());
      expect(asyncValues[3], isA<AsyncData<void>>());
    });

    test('keep state in cache if last one was data', () async {
      final asyncValues = <AsyncValue<void>>[];

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(queryDuration);

      firstSubscription.close();

      expect(asyncValues.length, 2);
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

      await Future<void>.delayed(queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, 2);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
    });

    test(
        '''keep state in cache if last one was loading and end up being data while not watching it''',
        () async {
      final asyncValues = <AsyncValue<void>>[
        container.read(testFutureProvider),
      ];

      expect(asyncValues.length, 1);
      expect(asyncValues[0], isA<AsyncLoading<void>>());

      await Future<void>.delayed(queryDuration);
      await Future<void>.delayed(onDisposeComputingDuration);

      asyncValues.add(container.read(testFutureProvider));

      expect(asyncValues.length, 2);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
    });

    test(
        '''do not keep state in cache if last one was loading and end up being error while not watching it''',
        () async {
      final asyncValues = <AsyncValue<void>>[];

      isData = false;

      asyncValues.add(container.read(testFutureProvider));

      expect(asyncValues.length, 1);
      expect(asyncValues[0], isA<AsyncLoading<void>>());

      await Future<void>.delayed(queryDuration);
      await Future<void>.delayed(onDisposeComputingDuration);

      asyncValues.add(container.read(testFutureProvider));

      expect(asyncValues.length, 2);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncLoading<void>>());
    });

    test('reset state if we wait more than cacheTime', () async {
      final asyncValues = <AsyncValue<void>>[];

      final firstSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(queryDuration);

      firstSubscription.close();

      expect(asyncValues.length, 2);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());

      await Future<void>.delayed(dataCacheDuration);
      await Future<void>.delayed(onDisposeComputingDuration);

      final secondSubscription =
          container.listen(testFutureProvider, (previous, next) {
        if (previous != null) {
          asyncValues.add(previous);
        }
        asyncValues.add(next);
      });

      await Future<void>.delayed(queryDuration);

      secondSubscription.close();

      expect(asyncValues.length, 4);
      expect(asyncValues[0], isA<AsyncLoading<void>>());
      expect(asyncValues[1], isA<AsyncData<void>>());
      expect(asyncValues[2], isA<AsyncLoading<void>>());
      expect(asyncValues[3], isA<AsyncData<void>>());
    });
  });
}
