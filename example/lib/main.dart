import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';

part 'main.g.dart';

@riverpod
Future<int> cacheDataFor(CacheDataForRef ref) async {
  ref.cacheDataFor(const Duration(seconds: 4));
  await Future.delayed(const Duration(seconds: 3));
  return 42;
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Future<int>? data = ref.read(cacheDataForProvider.future);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gets mock data. After 3 seconds, it returns 42, and then cache the result for 4 seconds.',
            ),
            const Divider(indent: 20, endIndent: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: const Text(
                    'get data once again',
                  ),
                  onPressed: () {
                    setState(() {
                      data = ref.read(cacheDataForProvider.future);
                    });
                  },
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                      future: data,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text('data:${snapshot.data.toString()}');
                        }
                        return const CircularProgressIndicator();
                      }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
