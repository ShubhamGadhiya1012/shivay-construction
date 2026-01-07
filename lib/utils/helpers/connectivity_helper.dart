import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ConnectivityHelper {
  ConnectivityHelper._internal() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  static final ConnectivityHelper instance = ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      _isConnected = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected =
        results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  Future<void> runIfConnected(
    Future<void> Function() action, {
    String? message,
  }) async {
    final connected = await checkConnectivity();
    if (connected) {
      await action();
    } else {
      showErrorSnackbar(
        "No Internet",
        message ?? "Please connect to the internet",
      );
    }
  }

  Future<void> navigateIfConnected(
    GetPageBuilder page, {
    String? message,
  }) async {
    await runIfConnected(
      () async => Get.to(page),
      message: message ?? "Please connect to the internet to continue",
    );
  }
}
