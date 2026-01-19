import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class StockReportRepo {
  static Future<List<StockReportDm>> getStockReport({
    required String fromDate,
    required String toDate,
    required String rType,
    required String method,
    required String siteCode,
    required String gdCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Report/stockReport',
        requestBody: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'RTYPE': rType,
          'METHOD': method,
          'SiteCode': siteCode,
          'GDCode': gdCode,
          'ICode': iCode,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => StockReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
