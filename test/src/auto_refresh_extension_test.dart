import 'package:riverpod/riverpod.dart';
import 'package:riverpods_community_extensions/src/auto_refresh_extension.dart';
import 'package:test/test.dart';

void main() {
  group('auto-refresh extension', () {
    const timeInterval = Duration(milliseconds: 500);
    const moreThanTimeInterval = Duration(milliseconds: 600);
    const lessThanTimeInterval = Duration(milliseconds: 400);

    var isInvalidated = false;

    final myProvider = Provider.autoDispose<int>((ref) {
      ref
        ..autoRefresh(timeInterval)
        ..onDispose(() {
          isInvalidated = true;
        });
      return 42;
    });

    late ProviderContainer container;

    setUp(() {
      isInvalidated = false;
      container = ProviderContainer()..listen(myProvider, (_, __) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('autoRefresh calls invalidate if the time interval is reached',
        () async {
      expect(isInvalidated, false);

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      expect(isInvalidated, true);
    });

    test(
        'autoRefresh does not call invalidate if the time interval is not '
        'reached', () async {
      expect(isInvalidated, false);

      await Future<void>.delayed(
        lessThanTimeInterval,
      );

      expect(isInvalidated, false);
    });

    test('autoRefresh can be called multiple times', () async {
      expect(isInvalidated, false);

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      expect(isInvalidated, true);

      isInvalidated = false;

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      expect(isInvalidated, true);
    });
  });
}
