import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Stream<bool> get isOfflineStream {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.every((r) => r == ConnectivityResult.none),
    );
  }

  Future<bool> get isOffline async {
    final results = await _connectivity.checkConnectivity();
    return results.every((r) => r == ConnectivityResult.none);
  }
}

final connectivityProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});
