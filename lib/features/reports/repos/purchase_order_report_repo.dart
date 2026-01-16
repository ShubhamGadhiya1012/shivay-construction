import 'package:shivay_construction/features/reports/models/purchase_order_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PurchaseOrderReportRepo {
  static Future<List<PurchaseOrderReportDm>> getPurchaseOrderReport({
    required String fromDate,
    required String toDate,
    required String status,
    required String pCode,
    required String siteCode,
    required String gdCode,

    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/purchaseOrderReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'Status': status,
          'PCode': pCode,
          'SiteCode': siteCode,
          'GDCode': gdCode,

          'ICode': iCodes,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => PurchaseOrderReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
