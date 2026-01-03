import 'package:shivay_construction/features/godown%20master/models/godown_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class GodownMasterRepo {
  static Future<List<GodownMasterDm>> getGodowns() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getGodown',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => GodownMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> addUpdateGodown({
    required String gdCode,
    required String gdName,
    required String siteCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "GDCode": gdCode,
      "GDName": gdName,
      "SiteCode": siteCode,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addGodownMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
