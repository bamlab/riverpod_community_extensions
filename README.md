# Riverpod Community Extensions

<p>
  <a href="https://apps.theodo.com">
  <img  alt="logo" src="https://raw.githubusercontent.com/bamlab/riverpod_community_extensions/main/doc/theodo_apps_white.png" width="200"/>
  </a>
  </br>
  <p>Useful extensions on ref types for Riverpod.</p>

  <p>Ref types are the way to interact with providers in Riverpod. They are built to be composable and flexible. This package provides some useful extensions on ref types to make them even more powerful and easily add common functionalities on your providers, such as auto-refreshing for example.</p>
</p>

## Riverpod Versions 🔖

Riverpod Community Extensions version 2 is only compatible with riverpod 2.
If you want to use riverpod 3, migrate to riverpod_community_extension v3.

## Features 🚀

This package adds the following methods to ref types:

- `cacheFor` on `Ref` - Prevents the provider from being disposed for the specified duration.

- `cacheDataFor` on `AsyncNotifier` - Keeps the data of the Async Notifier for the specified duration.

- `debounce` on `Ref` - Wait for a specified duration before calling the provider's computation, and cancel the previous call if a new one is made.

- `autoRefresh` on `Ref` - Refreshes the value at a specified interval. Useful for scenarios where periodic updates of a provider's value are required.

- `refreshWhenReturningToForeground` on `Ref` - Refreshes the provider's value each time the app returns to the foreground, ensuring the data is always up to date after returning to the app.

- `refreshWhenNetworkAvailable` on `Ref` - Automatically refresh the provider when the network is available if it has error state. Uses the package [connectivity_plus](https://pub.dev/packages/connectivity_plus). Will only for inside FutureProvider.

## Installation 💻

**❗ In order to start using Riverpod Community Extensions you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add riverpod_community_extensions
```

## Usage 🎨

Simply import the package and use the provided extensions on your ref types.

Example without codegen:

```dart
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';
import 'package:riverpod/riverpod.dart';

final dataProvider = AsyncNotifierProvider<DataNotifier, int>(
  DataNotifier.new,
  isAutoDispose: true,
);
class DataNotifier extends AutoDisposeAsyncNotifier<int> {
  @override
  Future<int> build() async {
    ref.cacheDataFor(const Duration(minutes: 5));
    return await fetchDataFromApi();
  }
}
```

Example with codegen:

```dart
import 'package:riverpod_community_extensions/riverpod_community_extensions.dart';
import 'package:riverpod/riverpod.dart';

part 'data_provider.g.dart';

@riverpod
class DataNotifier extends _$DataNotifier {
  @override
  Future<int> build() async {
    ref.cacheDataFor(const Duration(minutes: 5));

    return await fetchUserFromApi();
  }
}
```

---

## 👉 About Theodo apps

We are a 130 people company developing and designing universal applications with [React Native](https://apps.theodo.com/expertise/react-native) and [Flutter](https://apps.theodo.com/expertise/flutter) using the Lean & Agile methodology. To get more information on the solutions that would suit your needs, feel free to get in touch by [email](mailto://contact-apps@theodo.com) or through or [contact form](https://apps.theodo.com/contact)!

We will always answer you with pleasure 😁

---

## Contributing 🤝

If you want to contribute to this project, please read the [CONTRIBUTE.md](CONTRIBUTE.md) file.
