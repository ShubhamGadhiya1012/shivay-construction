import 'package:shivay_construction/features/site_transfer/models/site_transfer_stock_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class RepairEntryRepo {
  static Future<List<SiteTransferStockDm>> getStockItems({
    required String siteCode,
    required String gdCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Transfer/getSiteStock?SiteCode=$siteCode&GDCode=$gdCode',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => SiteTransferStockDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> saveRepairIssue({
    required String invNo,
    required String date,
    required String pCode,
    required String description,
    required String fromSite,
    required String fromGDCode,
    required List<Map<String, dynamic>> itemData,
    required String remarks,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        "Invno": invNo,
        "Date": date,
        "PCode": pCode,
        "Description": description,
        "FromSite": fromSite,
        "FromGDCode": fromGDCode,
        "ItemData": itemData,
        "Remarks": remarks,
      };

      // print('---- REPAIR ISSUE PAYLOAD ----');
      // print(requestBody);

      final response = await ApiService.postRequest(
        endpoint: '/Transfer/issueRepair',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> receiveRepair({
    required String refInvNo,
    required String date,
    required String pCode,
    required String toSite,
    required String toGDCode,
    required List<Map<String, dynamic>> itemData,
    required String remarks,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        "RefInvno": refInvNo,
        "Date": date,
        "PCode": pCode,
        "ToSite": toSite,
        "ToGDCode": toGDCode,
        "ItemData": itemData,
        "Remarks": remarks,
      };

      // print('---- RECEIVE REPAIR PAYLOAD ----');
      // print(requestBody);

      final response = await ApiService.postRequest(
        endpoint: '/Transfer/receiveRepair',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
