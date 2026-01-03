import 'package:shivay_construction/features/site%20master/models/site_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteMasterListRepo {
  static Future<List<SiteMasterDm>> getSites() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getSite',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => SiteMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
