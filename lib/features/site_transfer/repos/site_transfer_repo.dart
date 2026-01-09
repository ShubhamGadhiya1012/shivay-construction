// repos/site_transfer_repo.dart
import 'package:shivay_construction/features/site_transfer/models/site_transfer_stock_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteTransferRepo {
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
    required String date,
    required String fromSite,
    required String toSite,
    required String fromGDCode,
    required String toGDCode,
    required String remarks,
    required List<Map<String, dynamic>> itemData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        "Date": date,
        "FromSite": fromSite,
        "ToSite": toSite,
        "FromGDCode": fromGDCode,
        "ToGDCode": toGDCode,
        "Remarks": remarks,
        "ItemData": itemData,
      };

      print(requestBody);

      final response = await ApiService.postRequest(
        endpoint: '/Transfer/siteTransfer',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
