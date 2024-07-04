# Riverpods Community Extensions

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

Useful extensions on ref types for Riverpod.

Ref types are the way to interact with providers in Riverpod. They are built to be composable and flexible. This package provides some useful extensions on ref types to make them even more powerful and easily add common functionalities on your providers, such as auto-refreshing for example.

## Features 🚀

This package adds the following methods to ref types:

- `cacheFor` on `AutoDisposeRef` - Prevents the provider from being disposed for the specified duration.

- `cacheDataFor` on `AutoDisposeFutureProviderRef` - Keeps the data of the future provider for the specified duration.

- `debounce` on `AutoDisposeFutureProviderRef` - Wait for a specified duration before calling the provider's computation, and cancel the previous call if a new one is made.

- `refreshWhenNetworkAvailable` on `AutoDisposeFutureProviderRef` - Automatically refresh the provider when the network is available. Uses the package [connectivity_plus](https://pub.dev/packages/connectivity_plus).

## Installation 💻

**❗ In order to start using Riverpods Community Extensions you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add riverpods_community_extensions
```

## Usage 🎨

Simply import the package and use the provided extensions on your ref types.

Example without codegen:

```dart
import 'package:riverpods_community_extensions/riverpods_community_extensions.dart';
import 'package:riverpod/riverpod.dart';

final dataProvider = FutureProvider.autoDispose((ref) async {
  ref.cacheDataFor(const Duration(minutes: 5));
  return fetchData();
});

```

Example with codegen:

```dart
import 'package:riverpods_community_extensions/riverpods_community_extensions.dart';
import 'package:riverpod/riverpod.dart';

part 'data_provider.g.dart';

@riverpod
Future<int> data((ref) async {
  ref.cacheDataFor(const Duration(minutes: 5));
  return fetchData();
});

```

---

## 👉 About Theodo apps

We are a 100 people company of the [Theodo group](https://www.theodo.fr/), developing and designing multiplatform applications with [React Native](https://www.bam.tech/expertise/react-native) and [Flutter](https://www.bam.tech/expertise/flutter) using the Lean & Agile methodology. To get more information on the solutions that would suit your needs, feel free to get in touch by [email](mailto:contact@bam.tech) or through or [contact form](https://www.bam.tech/contact)!

We will always answer you with pleasure 😁

---

## Contributing 🤝

If you want to contribute to this project, please read the [CONTRIBUTE.md](CONTRIBUTE.md) file.

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
