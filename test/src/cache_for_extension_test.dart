import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/cache_for_extension.dart';

void main() {
  group('ProviderCache', () {
    group('cacheFor extension', () {
      const cacheDuration = Duration(milliseconds: 20);
      const defaultStateValue = 0;
      const onDisposeComputingDuration = Duration(milliseconds: 1);

      var container = ProviderContainer();
      var testStateProvider = StateProvider.autoDispose<int>((ref) => 0);

      setUp(() {
        container = ProviderContainer();
        testStateProvider = StateProvider.autoDispose<int>((ref) {
          ref.cacheFor(cacheDuration);
          return defaultStateValue;
        });
      });

      tearDown(() {
        container.dispose();
      });

      test('return value from cache if it has one', () async {
        const newStateValue = 1;

        container.read(testStateProvider.notifier).state = newStateValue;

        // wait for a duration inferior to cacheDuration
        await Future<void>.delayed(const Duration(milliseconds: 1));

        expect(container.read(testStateProvider), newStateValue);
      });

      test('re-instanciate provider if no value is in cache', () async {
        container.read(testStateProvider.notifier).state = 1;

        await Future<void>.delayed(cacheDuration);
        // Simulate an event loop
        await Future<void>.delayed(onDisposeComputingDuration);

        expect(container.read(testStateProvider), defaultStateValue);
      });
    });
  });
}
