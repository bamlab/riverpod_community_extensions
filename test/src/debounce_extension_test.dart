import 'package:riverpod/riverpod.dart';
import 'package:riverpods_community_extensions/src/debounce_extension.dart';
import 'package:test/test.dart';

void main() {
  group('debounce extension', () {
    final executionCounterProvider = StateProvider((ref) => 0);

    // Define a FutureProvider that uses debounce.
    final myFutureProvider = FutureProvider.autoDispose<int>((ref) async {
      await ref.debounce(const Duration(milliseconds: 300));
      ref.read(executionCounterProvider.notifier).state += 1;
      return 42; // Some dummy result.
    });

    test('debounce delays the execution', () async {
      final container = ProviderContainer();
      expect(container.read(executionCounterProvider), 0);
      container.listen(myFutureProvider, (_, __) {});

      expect(container.read(executionCounterProvider), 0);
      // Wait for 400 milliseconds, longer than the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(container.read(executionCounterProvider), 1);
    });

    test(
        'debounce cancels the first execution '
        'if it is relaunched before the debounce duration', () async {
      final lastTriggeredValueProvider = StateProvider((ref) => 1);
      final executionValuesProvider = StateProvider((ref) => 0);

      // Define a FutureProvider that uses debounce.
      final myFutureProvider = FutureProvider.autoDispose<int>((ref) async {
        await ref.debounce(const Duration(milliseconds: 300));
        ref.read(executionValuesProvider.notifier).state +=
            ref.read(lastTriggeredValueProvider);
        return 42; // Some dummy result.
      });

      final container = ProviderContainer();
      expect(container.read(executionValuesProvider), 0);
      container.listen(myFutureProvider, (_, __) {});
      // relaunch before the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      container.read(lastTriggeredValueProvider.notifier).state = 10;
      container.listen(myFutureProvider, (_, __) {});

      // Wait for 700 milliseconds, longer than the debounce duration.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(container.read(executionValuesProvider), 10);
    });

    test('debounce handles dispose error', () async {
      final container = ProviderContainer();
      final future = container.read(myFutureProvider.future);

      container.dispose();
      try {
        await future;
      } catch (e) {
        expect(e, isA<StateError>());
      }
    });
  });
}
