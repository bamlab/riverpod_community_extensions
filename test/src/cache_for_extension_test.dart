import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/cache_for_extension.dart';

class _TestStateProvider extends Notifier<int> {
  @override
  int build() {
    ref.cacheFor(_cacheDuration);

    return 0;
  }
}

const _cacheDuration = Duration(milliseconds: 20);

void main() {
  group('ProviderCache', () {
    group('cacheFor extension', () {
      const defaultStateValue = 0;
      const onDisposeComputingDuration = Duration(milliseconds: 1);

      late ProviderContainer container;
      late NotifierProvider testStateProvider;

      setUp(() {
        container = ProviderContainer();
        testStateProvider = NotifierProvider<_TestStateProvider, int>(
          _TestStateProvider.new,
          isAutoDispose: true,
          retry: (_, __) => null,
        );
      });

      tearDown(() {
        container.dispose();
      });

      test('return value from cache if it has one', () async {
        const newStateValue = 1;

        container.read(testStateProvider.notifier).state = newStateValue;

        // wait for a duration inferior to cacheDuration
        await Future<void>.delayed(const Duration(milliseconds: 1));

        expect(container.read(testStateProvider), equals(newStateValue));
      });

      test('re-instanciate provider if no value is in cache', () async {
        container.read(testStateProvider.notifier).state = 1;

        await Future<void>.delayed(_cacheDuration);
        // Simulate an event loop
        await Future<void>.delayed(onDisposeComputingDuration);

        expect(container.read(testStateProvider), equals(defaultStateValue));
      });
    });
  });
}
