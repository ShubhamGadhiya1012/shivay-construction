import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class UserAuthorisationRepo {
  static Future<dynamic> authoriseUser({
    required int userId,
    required int userType,
    required String pCodes,
    required String seCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "userId": userId,
      "userType": userType,
      "PCODEs": pCodes,
      "SECODEs": seCodes,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/Authorise',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
