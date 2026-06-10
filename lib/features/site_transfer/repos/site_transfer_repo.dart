import 'package:shivay_construction/features/site_transfer/models/site_transfer_stock_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteTransferRepo {
  static Future<List<Map<String, dynamic>>> getItemStockForGodown({
    required String siteCode,
    required String gdCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Indent/getSiteWiseStock?ICode=$iCode&SiteCode=$siteCode',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        // Filter by GDCode
        final filtered = data
            .where((item) => item['GDCode'] == gdCode)
            .toList();

        return filtered
            .map(
              (item) => {
                'stockQty': (item['StockQty'] as num?)?.toDouble() ?? 0.0,
                'unit': item['Unit'] ?? '',
              },
            )
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<SiteTransferStockDm>> getSiteStock({
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

  static Future<dynamic> saveSiteTransfer({
    required String invNo,
    required String date,
    required String fromSite,
    required String toSite,
    required String remarks,
    required List<Map<String, dynamic>> itemData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        "Invno": invNo,
        "Date": date,
        "FromSite": fromSite,
        "ToSite": toSite,
        "Remarks": remarks,
        "ItemData": itemData,
      };
      print(requestBody);
      final response = await ApiService.postRequest(
        endpoint: '/Transfer/siteTransferIssue',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> receiveSiteTransfer({
    required String refInvNo,
    required String date,
    required String fromSite,
    required String toSite,
    required List<Map<String, dynamic>> itemData,
    required String remarks,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        "RefInvno": refInvNo,
        "Date": date,
        "FromSite": fromSite,
        "ToSite": toSite,
        "ItemData": itemData,
        "Remarks": remarks,
      };
      print(requestBody);
      final response = await ApiService.postRequest(
        endpoint: '/Transfer/siteTransferReceive',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteSiteTransfer({required String invNo}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {"Invno": invNo};

      final response = await ApiService.postRequest(
        endpoint: '/Transfer/siteTransferDelete',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
