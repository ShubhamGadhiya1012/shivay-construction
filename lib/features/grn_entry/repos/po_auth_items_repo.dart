import 'package:shivay_construction/features/grn_entry/models/po_auth_item_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PoAuthItemsRepo {
  static Future<List<PoAuthItemDm>> getPoAuthItems({
    required String siteCode,
    required String gdCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/GRN/getPOAuthItems',
        queryParams: {'SiteCode': siteCode, 'GDCode': gdCode},
        token: token,
      );

      //  print(response);
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => PoAuthItemDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
