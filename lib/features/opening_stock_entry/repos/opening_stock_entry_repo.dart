import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class OpeningStockEntryRepo {
  static Future<dynamic> saveOpeningStockEntry({
    required String invNo,
    required String date,
    required String siteCode,
    required String gdCode,
    required List<Map<String, dynamic>> itemData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "Invno": invNo,
      "Date": date,
      "SiteCode": siteCode,
      "GDCode": gdCode,
      "ItemData": itemData,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Entry/openingStockEntry',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
