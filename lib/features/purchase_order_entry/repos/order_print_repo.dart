import 'package:shivay_construction/features/purchase_order_entry/models/order_print_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class OrderPrintRepo {
  static Future<OrderPrintDm?> getOrderPrintData({
    required String invNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Order/getOrderPrintData',
        queryParams: {'Invno': invNo},
        token: token,
      );

      if (response == null) return null;

      return OrderPrintDm.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
