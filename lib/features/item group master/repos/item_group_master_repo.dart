import 'package:shivay_construction/features/item%20group%20master/models/item_group_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class ItemGroupMasterRepo {
  static Future<List<ItemGroupMasterDm>> getItemGroups() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getItemGroup',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => ItemGroupMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> addUpdateItemGroup({
    required String igCode,
    required String igName,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "IGCode": igCode,
      "IGName": igName,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addItemGroupMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
