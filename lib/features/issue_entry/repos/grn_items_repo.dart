import 'package:shivay_construction/features/issue_entry/models/grn_item_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class GrnItemsForIssueRepo {
  static Future<List<GrnItemForIssueDm>> getGrnItems() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Issue/getGRNItems',
        token: token,
      );
      if (response == null) return [];
      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => GrnItemForIssueDm.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
