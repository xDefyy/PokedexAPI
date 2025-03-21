import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnectedToWifi() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.none) ? false : true;
  }
}
