import 'package:shivay_construction/features/auth/models/company_dm.dart';
import 'package:shivay_construction/services/api_service.dart';

class LoginRepo {
  static Future<List<CompanyDm>> loginUser({
    required String mobileNo,
    required String password,
    required String fcmToken,
    required String deviceId,
  }) async {
    final Map<String, dynamic> requestBody = {
      'mobileNo': mobileNo,
      'password': password,
      'FCMToken': fcmToken,
      'DeviceID': deviceId,
    };
    print('Login Request Body: $requestBody');
    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/login',
        requestBody: requestBody,
      );

      if (response != null && response['company'] != null) {
        return (response['company'] as List<dynamic>)
            .map((companyJson) => CompanyDm.fromJson(companyJson))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> getToken({
    required String mobileNumber,
    required int cid,
    required int yearId,
  }) async {
    final Map<String, dynamic> requestBody = {
      'mobileno': mobileNumber,
      'cid': cid,
      'yearId': yearId,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/token',
        requestBody: requestBody,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
