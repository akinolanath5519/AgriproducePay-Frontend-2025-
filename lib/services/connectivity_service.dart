import 'dart:async';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(ref);
});

class ConnectivityService {
  final Ref ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService(this.ref);

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      // Since results is a List<ConnectivityResult>, check if it contains mobile or wifi
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        // Internet is back → sync unsynced commodities
        await ref.read(commodityProvider).syncLocalToServer(ref as WidgetRef);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
