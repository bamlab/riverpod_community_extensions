import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';

/// A stream provider that listens to network connectivity changes.
final connectivityStreamProvider = StreamProvider(
  (ref) => Connectivity().onConnectivityChanged.distinct(),
);
