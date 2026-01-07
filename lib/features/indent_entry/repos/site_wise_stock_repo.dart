import 'package:shivay_construction/features/indent_entry/models/site_wise_stock_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteWiseStockRepo {
  static Future<List<SiteWiseStockDm>> getSiteWiseStock({String? iCode}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Indent/getSiteWiseStock',
        queryParams: iCode != null ? {'ICode': iCode} : null, // Add this
        token: token,
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => SiteWiseStockDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
