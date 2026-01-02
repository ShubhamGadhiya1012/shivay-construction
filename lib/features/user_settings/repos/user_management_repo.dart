import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class UserManagementRepo {
  static Future<dynamic> manageUser({
    required int userId,
    required String fullName,
    required String mobileNo,
    required String password,
    required int userType,
    required String pCodes,
    required String seCodes,
    required String eCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "userId": userId,
      "FullName": fullName,
      "mobileNo": mobileNo,
      "password": password,
      "userType": userType,
      "PCODEs": pCodes,
      "SECODEs": seCodes,
      "ECODEs": eCodes,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/User/manageUser',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
