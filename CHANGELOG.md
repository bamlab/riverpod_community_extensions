# 3.0.0

 - feat: Support for Riverpod 3!

 - BREAKING: cacheDataFor cannot be used on FutureProvider. Instead use it on AsyncNotifier.
 - BREAKING: refreshWhenNetworkAvailable cannot be used on FutureProvider. Instead use it on AsyncNotifier.

 Some extensions that were previously available on FutureProvider are now only usable inside AsyncNotifier. This is due to the fact that `Ref` does not take a generic type parameter anymore.
 See: 
  - [One ref to rule them all](https://riverpod.dev/docs/whats_new#one-ref-to-rule-them-all)
  - [Discussion](https://github.com/rrousselGit/riverpod/discussions/4305)

# 2.0.0

First stable release of riverpod_community_extension.
Compatible with riverpod 2.

All extensions are now usable on Ref instead of AutoDisposeFutureProviderRef and AutoDisposeRef.

# 0.1.0+1

- feat: initial release 🎉

# 0.1.1

- doc: fix readme formatting