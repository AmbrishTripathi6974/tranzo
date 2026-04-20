abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Placeholder implementation; will be replaced with connectivity checks.
    return true;
  }
}
