import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkConnectionType { none, wifi, mobile, other }

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Future<NetworkConnectionType> get connectionType;
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
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkConnectionType.none;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkConnectionType.mobile;
    }
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return NetworkConnectionType.wifi;
    }
    return NetworkConnectionType.other;
  }
}
