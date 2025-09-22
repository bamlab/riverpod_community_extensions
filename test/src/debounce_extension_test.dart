import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_community_extensions/src/debounce_extension.dart';

final _lastTriggeredValueProvider =
    NotifierProvider<_LastTriggeredValueProvider, int>(
  _LastTriggeredValueProvider.new,
  retry: (_, __) => null,
);

class _LastTriggeredValueProvider extends Notifier<int> {
  @override
  int build() {
    return 1;
  }
}

final _executionCounterProvider =
    NotifierProvider<_ExecutionCounterProvider, int>(
  _ExecutionCounterProvider.new,
  retry: (_, __) => null,
);

class _ExecutionCounterProvider extends Notifier<int> {
  @override
  int build() {
    return 0;
  }
}

void main() {
  group('debounce extension', () {
    FutureProvider<int> createTestProvider() {
      return FutureProvider.autoDispose<int>(
        (ref) async {
          await ref.debounce(const Duration(milliseconds: 300));
          ref.read(_executionCounterProvider.notifier).state +=
              ref.read(_lastTriggeredValueProvider);

          return 42;
        },
        retry: (_, __) => null,
      );
    }

    test('debounce delays the execution', () async {
      final container = ProviderContainer();
      expect(container.read(_executionCounterProvider), equals(0));
      container.listen(createTestProvider(), (_, __) {});

      expect(container.read(_executionCounterProvider), equals(0));
      // Wait for 400 milliseconds, longer than the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(container.read(_executionCounterProvider), equals(1));
    });

    test(
        'debounce cancels the first execution '
        'if it is relaunched before the debounce duration', () async {
      // Define a FutureProvider that uses debounce.
      final localFutureProvider = FutureProvider.autoDispose<int>((ref) async {
        await ref.debounce(const Duration(milliseconds: 300));
        ref.read(_executionCounterProvider.notifier).state +=
            ref.read(_lastTriggeredValueProvider);

        return 42; // Some dummy result.
      });

      final container = ProviderContainer();
      expect(container.read(_executionCounterProvider), equals(0));
      container.listen(localFutureProvider, (_, __) {});
      // relaunch before the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      container.read(_lastTriggeredValueProvider.notifier).state = 10;
      container.listen(localFutureProvider, (_, __) {});

      // Wait for 700 milliseconds, longer than the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(container.read(_executionCounterProvider), equals(10));
    });

    test('debounce handles dispose error', () async {
      final container = ProviderContainer();
      final future = container.read(createTestProvider().future);

      container.dispose();
      try {
        await future;
      } catch (e) {
        expect(e, isA<StateError>());
      }
    });
  });
}
