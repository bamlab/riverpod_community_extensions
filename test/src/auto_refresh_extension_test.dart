import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpods_community_extensions/src/auto_refresh_extension.dart';

void main() {
  group('auto-refresh extension', () {
    const timeInterval = Duration(milliseconds: 500);
    const moreThanTimeInterval = Duration(milliseconds: 600);
    const lessThanTimeInterval = Duration(milliseconds: 400);

    var numberOfFetchDataCalls = 0;

    int fetchData() {
      numberOfFetchDataCalls++;
      return 42;
    }

    final myProvider = Provider.autoDispose<int>((ref) {
      ref.autoRefresh(timeInterval);
      return fetchData();
    });

    late ProviderContainer container;

    setUp(() {
      numberOfFetchDataCalls = 0;
      container = ProviderContainer()..listen(myProvider, (_, __) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('autoRefresh refreshes if the time interval is reached', () async {
      // The value should be fetched initially
      expect(numberOfFetchDataCalls, 1);

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      // The value should be refreshed after the time interval
      expect(numberOfFetchDataCalls, 2);
    });

    test('autoRefresh does not refresh if the time interval is not reached',
        () async {
      // The value should be fetched initially
      expect(numberOfFetchDataCalls, 1);

      await Future<void>.delayed(
        lessThanTimeInterval,
      );

      // The value should not be refreshed after the time interval
      expect(numberOfFetchDataCalls, 1);
    });

    test('autoRefresh can refresh multiple times', () async {
      // The value should be fetched initially
      expect(numberOfFetchDataCalls, 1);

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      // The value should be refreshed after the time interval
      expect(numberOfFetchDataCalls, 2);

      await Future<void>.delayed(
        moreThanTimeInterval,
      );
      // The value should be refreshed after the time interval
      expect(numberOfFetchDataCalls, 3);
    });
  });

  group('refreshWhenReturningToForeground', () {
    var numberOfFetchDataCalls = 0;

    int fetchData() {
      numberOfFetchDataCalls++;
      return 42;
    }

    final myProvider = Provider.autoDispose<int>((ref) {
      ref.refreshWhenReturningToForeground();
      return fetchData();
    });

    late ProviderContainer container;

    setUp(() {
      numberOfFetchDataCalls = 0;
      container = ProviderContainer()..listen(myProvider, (_, __) {});
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('can refresh when returning to foreground', (tester) async {
      // The value should be fetched initially
      expect(numberOfFetchDataCalls, 1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 2);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 3);
    });

    testWidgets('can be properly disposed', (tester) async {
      // The value should be fetched initially
      expect(numberOfFetchDataCalls, 1);

      container.dispose();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(numberOfFetchDataCalls, 1);
    });
  });
}
