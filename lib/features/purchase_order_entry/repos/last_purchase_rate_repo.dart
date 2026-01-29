import 'package:shivay_construction/features/purchase_order_entry/models/last_purchase_rate_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class LastPurchaseRateRepo {
  static Future<List<LastPurchaseRateDm>> getLastPurchaseRate({
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(iCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Order/getLastPurchase',
        queryParams: {'ICode': iCode},
        token: token,
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => LastPurchaseRateDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
