import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  /// Sprawdź czy jest dostęp do internetu (dane/WiFi)
  static Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }
}
