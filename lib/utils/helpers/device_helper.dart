import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:shivay_construction/utils/helpers/platform_stub.dart'
    if (dart.library.io) 'package:shivay_construction/utils/helpers/platform_mobile.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';

class DeviceHelper {
  static const platform = MethodChannel('samples.flutter.dev/device');

  Future<String?> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();

    if (isAndroid && !AppScreenUtils.isWeb) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }
}
