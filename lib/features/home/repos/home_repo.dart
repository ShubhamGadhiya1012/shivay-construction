import 'package:shivay_construction/features/user_settings/models/user_access_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class HomeRepo {
  static Future<UserAccessDm> getUserAccess({required int userId}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/User/userAccess',
        queryParams: {'userId': userId.toString()},
        token: token,
      );

      if (response == null) {
        return UserAccessDm(
          menuAccess: [],
          ledgerDate: LedgerDateDm(ledgerStart: '', ledgerEnd: ''),
        );
      }

      return UserAccessDm.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> checkVersion({
    required String version,
    required String deviceId,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/version',
        token: token,
        queryParams: {'Version': version, 'DeviceID': deviceId},
      );

      if (response == null) {
        return [];
      }

      if (response is List) {
        return response;
      }

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        throw response['error'];
      }

      return [];
    } catch (e) {
      throw e.toString();
    }
  }
}