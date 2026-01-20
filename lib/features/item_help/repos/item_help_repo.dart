import 'package:shivay_construction/features/item_help/models/item_help_item_dm.dart';
import 'package:shivay_construction/features/item_help/models/item_help_detail_dm.dart';
import 'package:shivay_construction/features/item_help/models/item_help_last_grn_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class ItemHelpRepo {
  static Future<List<ItemHelpItemDm>> getItems({
    required String cCode,
    required String igCode,
    required String icCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "CCODE": cCode,
      "IGCODE": igCode,
      "ICCODE": icCode,
      "ICODE": iCode,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/ItemHelp/items',
        requestBody: requestBody,
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => ItemHelpItemDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ItemHelpDetailDm>> getItemDetails({
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/ItemHelp/itemDtl?ICode=$iCode',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => ItemHelpDetailDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ItemHelpLastGrnDm>> getLastGrn({
    required String iCode,
    required String pCode,
    required String count,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(pCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/ItemHelp/lastGRN?Count=$count&ICode=$iCode&PCode=$pCode',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => ItemHelpLastGrnDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
