import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkConnectionType { none, wifi, mobile, other }

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Future<NetworkConnectionType> get connectionType;
  Stream<NetworkConnectionType> get onConnectionChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async =>
      (await connectionType) != NetworkConnectionType.none;

  @override
  Future<NetworkConnectionType> get connectionType async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    return _mapConnectivityResults(results);
  }

  @override
  Stream<NetworkConnectionType> get onConnectionChanged {
    return _connectivity.onConnectivityChanged.map(_mapConnectivityResults);
  }
}

NetworkConnectionType _mapConnectivityResults(List<ConnectivityResult> r) {
  if (r.isEmpty || r.contains(ConnectivityResult.none)) {
    return NetworkConnectionType.none;
  }
  if (r.contains(ConnectivityResult.wifi) ||
      r.contains(ConnectivityResult.ethernet)) {
    return NetworkConnectionType.wifi;
  }
  if (r.contains(ConnectivityResult.mobile)) {
    return NetworkConnectionType.mobile;
  }
  return NetworkConnectionType.other;
}
